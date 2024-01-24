provider "azurerm" {
  features {}
}

locals {
  name        = "app"
  environment = "test"
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
  location    = "North Europe"
}

##-----------------------------------------------------------------------------
## Virtual Network module call.
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "clouddrove/vnet/azure"
  version             = "1.0.4"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.20.0.0/16"]
}

##-----------------------------------------------------------------------------
## Subnet module call.
## Delegated subnet for mysql.
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "clouddrove/subnet/azure"
  version              = "1.1.0"
  name                 = local.name
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name

  #subnet
  subnet_names      = ["default"]
  subnet_prefixes   = ["10.20.1.0/24"]
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
## Existing resource group where dns zone created
##-----------------------------------------------------------------------------
data "azurerm_resource_group" "main" {
  name = "app-test-resource-group"
}

##-----------------------------------------------------------------------------
## Data block for existing private dns zone.
## Required because for replication both flexible mysql servers must be in same private dns zone.
##-----------------------------------------------------------------------------
data "azurerm_private_dns_zone" "main" {
  depends_on          = [data.azurerm_resource_group.main]
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = data.azurerm_resource_group.main.name
}

##-----------------------------------------------------------------------------
## Flexible Mysql server module call.
##-----------------------------------------------------------------------------
module "flexible-mysql" {
  depends_on                     = [module.resource_group, module.vnet, data.azurerm_resource_group.main]
  source                         = "../../"
  name                           = local.name
  environment                    = local.environment
  main_rg_name                   = data.azurerm_resource_group.main.name
  resource_group_name            = module.resource_group.resource_group_name
  location                       = module.resource_group.resource_group_location
  virtual_network_id             = module.vnet.vnet_id
  delegated_subnet_id            = module.subnet.default_subnet_id[0]
  mysql_version                  = "8.0.21"
  zone                           = "1"
  admin_username                 = "mysqlusern"
  admin_password                 = "ba5yatgfgfhdsvvc6A3ns2lu4gqzzc"
  sku_name                       = "GP_Standard_D2ds_v4"
  db_name                        = "maindb"
  charset                        = "utf8"
  collation                      = "utf8_unicode_ci"
  auto_grow_enabled              = true
  iops                           = 360
  size_gb                        = "20"
  existing_private_dns_zone      = true
  existing_private_dns_zone_id   = data.azurerm_private_dns_zone.main.id
  existing_private_dns_zone_name = data.azurerm_private_dns_zone.main.name
  ##azurerm_mysql_flexible_server_configuration
  server_configuration_names = ["interactive_timeout", "audit_log_enabled"]
  values                     = ["600", "ON"]
}
