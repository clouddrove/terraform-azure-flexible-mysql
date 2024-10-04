provider "azurerm" {
  features {}
  subscription_id = "068245d4-3c94-42fe-9c4d-9e5e1cabc60c"
}

provider "azurerm" {
  features {}
  alias           = "peer"
  subscription_id = "068245d4-3c94-42fe-9c4d-9e5e1cabc60c"
}

data "azurerm_client_config" "current_client_config" {}

locals {
  name        = "lacoster-23"
  environment = "maximum-32"
  label_order = ["name", "environment"]
}

##----------------------------------------------------------------------------- 
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "clouddrove/resource-group/azure"
  version     = "1.0.2"
  name        = local.name
  environment = local.environment
  label_order = local.label_order
  location    = "Central India"
}

##----------------------------------------------------------------------------- 
## Virtual Network module call.
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "clouddrove/vnet/azure"
  version             = "1.0.3"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

##----------------------------------------------------------------------------- 
## Subnet module call.
## Delegated subnet for mysql.
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "clouddrove/subnet/azure"
  version              = "1.2.1"
  name                 = local.name
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet.vnet_name)
  #subnet
  subnet_names      = ["default"]
  subnet_prefixes   = ["10.0.1.0/24"]
  service_endpoints = ["Microsoft.Storage"]
  delegation = {
    flexibleServers_delegation = [
      {
        name    = "Microsoft.DBforMySQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    ]
  }
}

##----------------------------------------------------------------------------- 
## Key Vault module call.
##-----------------------------------------------------------------------------
module "vault" {
  source  = "clouddrove/key-vault/azure"
  version = "1.2.0"

  providers = {
    azurerm.dns_sub  = azurerm.peer,
    azurerm.main_sub = azurerm
  }

  name                        = "oliveware-23"
  environment                 = "vilod-32"
  label_order                 = ["name", "environment", ]
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  admin_objects_ids           = [data.azurerm_client_config.current_client_config.object_id]
  virtual_network_id          = module.vnet.vnet_id[0]
  subnet_id                   = module.subnet.default_subnet_id[0]
  enable_rbac_authorization   = true
  enabled_for_disk_encryption = false
  #private endpoint
  enable_private_endpoint = false
  network_acls            = null
  ########Following to be uncommnented only when using DNS Zone from different subscription along with existing DNS zone.

  # diff_sub                                      = true
  # alias                                         = ""
  # alias_sub                                     = ""

  #########Following to be uncommmented when using DNS zone from different resource group or different subscription.
  # existing_private_dns_zone                     = ""
  # existing_private_dns_zone_resource_group_name = ""

  #### enable diagnostic setting
  diagnostic_setting_enable  = false
  log_analytics_workspace_id = module.log-analytics.workspace_id ## when diagnostic_setting_enable enable,  add log analytics workspace id
}

##----------------------------------------------------------------------------- 
## Log Analytics module call.
##-----------------------------------------------------------------------------
module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "1.1.0"
  name                             = local.name
  environment                      = local.environment
  label_order                      = local.label_order
  create_log_analytics_workspace   = true
  log_analytics_workspace_sku      = "PerGB2018"
  retention_in_days                = 90
  daily_quota_gb                   = "-1"
  internet_ingestion_enabled       = true
  internet_query_enabled           = true
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
  log_analytics_workspace_id       = module.log-analytics.workspace_id
}

##----------------------------------------------------------------------------- 
## Flexible Mysql server module call.
##-----------------------------------------------------------------------------
module "flexible-mysql" {
  depends_on                 = [module.resource_group, module.vnet, module.vault]
  source                     = "../../"
  name                       = local.name
  environment                = local.environment
  resource_group_name        = module.resource_group.resource_group_name
  location                   = module.resource_group.resource_group_location
  virtual_network_id         = module.vnet.vnet_id[0]
  delegated_subnet_id        = module.subnet.default_subnet_id[0]
  mysql_version              = "8.0.21"
  private_dns                = true
  zone                       = "1"
  admin_username             = "mysqlusername"
  admin_password             = "ba5yatgfgfhdsv6A3ns2lu4gqzzc"
  sku_name                   = "GP_Standard_D8ds_v4"
  db_name                    = "maindb"
  charset                    = "utf8mb3"
  collation                  = "utf8mb3_unicode_ci"
  auto_grow_enabled          = true
  iops                       = 360
  size_gb                    = "20"
  server_configuration_names = ["interactive_timeout", "audit_log_enabled", "audit_log_events"]
  values                     = ["600", "ON", "CONNECTION,ADMIN,DDL,TABLE_ACCESS"]
  log_analytics_workspace_id = module.log-analytics.workspace_id
  key_vault_id               = module.vault.id
  key_vault_with_rbac        = true
  cmk_enabled                = true
}
