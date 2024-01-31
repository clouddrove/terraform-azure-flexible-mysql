data "azurerm_client_config" "current_client_config" {}

##-----------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##-----------------------------------------------------------------------------
module "labels" {
  source      = "clouddrove/labels/azure"
  version     = "1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

##-----------------------------------------------------------------------------
## Random Password Resource.
## Will be passed as admin password of mysql server when admin password is not passed manually as variable.
##-----------------------------------------------------------------------------
resource "random_password" "main" {
  count       = var.admin_password == null ? 1 : 0
  length      = var.admin_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false
}

##-----------------------------------------------------------------------------
## Below resource will create flexible mysql server in Azure environment.
##-----------------------------------------------------------------------------
resource "azurerm_mysql_flexible_server" "main" {
  count                             = var.enabled ? 1 : 0
  name                              = format("%s-mysql-flexible-server", module.labels.id)
  resource_group_name               = var.resource_group_name
  location                          = var.location
  administrator_login               = var.admin_username
  administrator_password            = var.admin_password == null ? random_password.main[0].result : var.admin_password
  backup_retention_days             = var.backup_retention_days
  delegated_subnet_id               = var.delegated_subnet_id
  private_dns_zone_id               = var.private_dns ? azurerm_private_dns_zone.main[0].id : var.existing_private_dns_zone_id
  sku_name                          = var.sku_name
  create_mode                       = var.create_mode
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  point_in_time_restore_time_in_utc = var.create_mode == "PointInTimeRestore" ? var.point_in_time_restore_time_in_utc : null
  replication_role                  = var.replication_role
  source_server_id                  = var.create_mode == "PointInTimeRestore" ? var.source_server_id : null
  storage {
    auto_grow_enabled = var.auto_grow_enabled
    iops              = var.iops
    size_gb           = var.size_gb
  }

  dynamic "high_availability" {
    for_each = toset(var.high_availability != null ? [var.high_availability] : [])
    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = lookup(high_availability.value, "standby_availability_zone", 1)
    }
  }

  dynamic "maintenance_window" {
    for_each = toset(var.maintenance_window != null ? [var.maintenance_window] : [])
    content {
      day_of_week  = lookup(maintenance_window.value, "day_of_week", 0)
      start_hour   = lookup(maintenance_window.value, "start_hour", 0)
      start_minute = lookup(maintenance_window.value, "start_minute", 0)
    }
  }

  dynamic "identity" {
    for_each = var.cmk_encryption_enabled && var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? [join("", azurerm_user_assigned_identity.identity.*.id)] : null
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.cmk_encryption_enabled ? [1] : []
    content {
      key_vault_key_id                  = var.key_vault_id != null ? azurerm_key_vault_key.kvkey[0].id : null
      primary_user_assigned_identity_id = var.key_vault_id != null ? azurerm_user_assigned_identity.identity[0].id : null
    }
  }

  version = var.mysql_version
  zone    = var.zone
  tags    = module.labels.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.main, azurerm_private_dns_zone_virtual_network_link.main2]
}

##-----------------------------------------------------------------------------
##A service principal of a special type is created in Microsoft Entra ID for the identity.
##-----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "identity" {
  count               = var.enabled && var.enabled_user_assigned_identity ? 1 : 0
  name                = format("mysql-identity-%s", module.labels.id)
  resource_group_name = var.resource_group_name
  location            = var.location
}
#
###-----------------------------------------------------------------------------
### Below resource will provide user access on key vault based on role base access in azure environment.
### if rbac is enabled then below resource will create.
###-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "rbac_keyvault_crypto_officer" {
  for_each             = toset(var.enabled && var.cmk_encryption_enabled ? var.admin_objects_ids : [])
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = each.value
}

###-----------------------------------------------------------------------------
### Below resource will assign 'Key Vault Crypto Service Encryption User' role to user assigned identity created above.
###-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "identity_assigned" {
  depends_on           = [azurerm_user_assigned_identity.identity]
  count                = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.identity[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

###-----------------------------------------------------------------------------
### Below resource will create key vault key that will be used for encryption.
###-----------------------------------------------------------------------------
resource "azurerm_key_vault_key" "kvkey" {
  depends_on      = [azurerm_role_assignment.identity_assigned, azurerm_role_assignment.rbac_keyvault_crypto_officer]
  count           = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  name            = format("%s-mysql-kv-key", module.labels.id)
  expiration_date = var.expiration_date
  key_vault_id    = var.key_vault_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  dynamic "rotation_policy" {
    for_each = var.rotation_policy != null ? var.rotation_policy : {}
    content {
      automatic {
        time_before_expiry = rotation_policy.value.time_before_expiry
      }

      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry
    }
  }
}

##-----------------------------------------------------------------------------
## Allows you to set a user or group as the AD administrator for an MySQL server in Azure
##-----------------------------------------------------------------------------
resource "azurerm_mysql_flexible_server_active_directory_administrator" "main" {
  for_each    = var.enabled ? var.user_object_id : {}
  server_id   = azurerm_mysql_flexible_server.main[0].id
  identity_id = var.identity_ids == null ? azurerm_user_assigned_identity.identity[0].id : var.identity_ids[0]
  login       = var.administrator_login_name
  object_id   = lookup(each.value, "object_id", "")
  tenant_id   = data.azurerm_client_config.current_client_config.tenant_id
}

##-----------------------------------------------------------------------------
## Below resource will create mysql flexible database.
##-----------------------------------------------------------------------------
resource "azurerm_mysql_flexible_database" "main" {
  for_each            = var.enabled ? toset(var.database_names) : []
  name                = each.value
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main[0].name
  charset             = var.charset
  collation           = var.collation
  depends_on          = [azurerm_mysql_flexible_server.main]
}

##-----------------------------------------------------------------------------
## Below resource will create flexible mysql server configuration.
##-----------------------------------------------------------------------------
resource "azurerm_mysql_flexible_server_configuration" "main" {
  count               = var.enabled ? length(var.server_configuration_names) : 0
  name                = element(var.server_configuration_names, count.index)
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main[0].name
  value               = element(var.values, count.index)
}

##-----------------------------------------------------------------------------
## Manages a Firewall Rule for a MySQL Flexible Server.
##-----------------------------------------------------------------------------
resource "azurerm_mysql_flexible_server_firewall_rule" "main" {
  count               = var.enabled && var.enable_firewall_rule ? 1 : 0
  name                = format("%s-mysql-firewall-rule", module.labels.id)
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main[0].name
  start_ip_address    = var.start_ip_address
  end_ip_address      = var.end_ip_address
}

##------------------------------------------------------------------------
## Manages a Customer Managed Key for a MySQL Server. - Default is "false"
##------------------------------------------------------------------------
resource "azurerm_mysql_server_key" "main" {
  count            = var.enabled && var.key_vault_key_id != null ? 1 : 0
  server_id        = azurerm_mysql_flexible_server.main[0].id
  key_vault_key_id = var.key_vault_key_id
}

##-----------------------------------------------------------------------------
## Below resource will deploy private dns for flexible mysql server.
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "main" {
  count               = var.enabled && var.private_dns ? 1 : 0
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = module.labels.tags
}

##-----------------------------------------------------------------------------
## Below resource will create vnet link in above created mysql private dns resource.
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  count                 = var.enabled && var.private_dns ? 1 : 0
  name                  = format("mysql-endpoint-link-%s", module.labels.id)
  private_dns_zone_name = azurerm_private_dns_zone.main[0].name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.resource_group_name
  registration_enabled  = var.registration_enabled
  tags                  = module.labels.tags
}

##-----------------------------------------------------------------------------
## Below resource will create vnet link in previously existing mysql private dns zone.
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "main2" {
  count                 = var.enabled && var.existing_private_dns_zone ? 1 : 0
  name                  = format("mysql-endpoint-link-%s", module.labels.id)
  private_dns_zone_name = var.existing_private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.main_rg_name
  registration_enabled  = var.registration_enabled
  tags                  = module.labels.tags
}

##-----------------------------------------------------------------------------
## Following resource will deploy diagnostic setting for flexible database.
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "mysql" {
  count                          = var.enabled && var.enable_diagnostic ? 1 : 0
  name                           = format("%s-mysql-diagnostic-log", module.labels.id)
  target_resource_id             = azurerm_mysql_flexible_server.main[0].id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_log" {
    for_each = var.log_category
    content {
      category       = enabled_log.value
      category_group = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = metric.value
      enabled  = true
    }
  }
  lifecycle {
    ignore_changes = [enabled_log, log_analytics_destination_type]
  }
}
