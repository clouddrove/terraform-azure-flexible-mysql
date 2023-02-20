## Vritual Network and Subnet Creation
data "azurerm_client_config" "current" {}

locals {
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "labels" {
  source      = "clouddrove/labels/azure"
  version     = "1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}


resource "azurerm_mysql_flexible_server" "main" {
  count                             = var.enabled ? 1 : 0
  name                              = format("%s-mysql-flexible-server", module.labels.id)
  resource_group_name               = local.resource_group_name
  location                          = var.location
  administrator_login               = var.admin_username
  administrator_password            = var.admin_password
  backup_retention_days             = var.backup_retention_days
  delegated_subnet_id               = var.delegated_subnet_id
  private_dns_zone_id               = var.private_dns ? join("", azurerm_private_dns_zone.main.*.id) : var.existing_private_dns_zone_id
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

  version = var.mysql_version
  zone    = var.zone

  tags = module.labels.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.main, azurerm_private_dns_zone_virtual_network_link.main2]
}

resource "azurerm_mysql_flexible_database" "main" {
  count               = var.enabled ? 1 : 0
  name                = var.db_name
  resource_group_name = local.resource_group_name
  server_name         = join("", azurerm_mysql_flexible_server.main.*.name)
  charset             = var.charset
  collation           = var.collation
  depends_on          = [azurerm_mysql_flexible_server.main]
}

resource "azurerm_mysql_flexible_server_configuration" "main" {
  count               = var.enabled ? length(var.server_configuration_names) : 0
  name                = element(var.server_configuration_names, count.index)
  resource_group_name = local.resource_group_name
  server_name         = join("", azurerm_mysql_flexible_server.main.*.name)
  value               = element(var.values, count.index)
}

##------------------------------------------------------------------------
## Manages a Customer Managed Key for a MySQL Server. - Default is "false"
##------------------------------------------------------------------------
resource "azurerm_mysql_server_key" "main" {
  count            = var.enabled && var.key_vault_key_id != null ? 1 : 0
  server_id        = join("", azurerm_mysql_flexible_server.main.*.id)
  key_vault_key_id = var.key_vault_key_id
}

resource "azurerm_private_dns_zone" "main" {
  count               = var.enabled && var.private_dns ? 1 : 0
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = local.resource_group_name
  tags                = module.labels.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  count                 = var.enabled && var.private_dns ? 1 : 0
  name                  = format("mysql-endpoint-link-%s", module.labels.id)
  private_dns_zone_name = join("", azurerm_private_dns_zone.main.*.name)
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = local.resource_group_name
  registration_enabled  = var.registration_enabled
  tags                  = module.labels.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main2" {
  count                 = var.enabled && var.existing_private_dns_zone ? 1 : 0
  name                  = format("mysql-endpoint-link-%s", module.labels.id)
  private_dns_zone_name = var.existing_private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.main_rg_name
  registration_enabled  = var.registration_enabled
  tags                  = module.labels.tags
}




