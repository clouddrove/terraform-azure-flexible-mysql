provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.2"

  name        = "app-mysqll2"
  environment = "test"
  label_order = ["name", "environment"]
  location    = "Canada Central"
}

module "vnet" {
  source              = "clouddrove/vnet/azure"
  version             = "1.0.2"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

module "subnet" {
  source               = "clouddrove/subnet/azure"
  version              = "1.0.2"
  name                 = "app"
  environment          = "test"
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

#existing resource group where dns zone created
data "azurerm_resource_group" "main" {
  name = "app-mysqll-test-resource-group"
}

data "azurerm_private_dns_zone" "main" {
  depends_on          = [data.azurerm_resource_group.main]
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = data.azurerm_resource_group.main.name
}

module "flexible-mysql" {
  depends_on                     = [module.resource_group, module.vnet, data.azurerm_resource_group.main]
  source                         = "clouddrove/flexible-mysql/azure"
  name                           = "app"
  environment                    = "test"
  main_rg_name                   = data.azurerm_resource_group.main.name
  resource_group_name            = module.resource_group.resource_group_name
  location                       = module.resource_group.resource_group_location
  virtual_network_id             = module.vnet.vnet_id[0]
  delegated_subnet_id            = module.subnet.default_subnet_id[0]
  mysql_version                  = "8.0.21"
  mysql_server_name              = "testmysqlserver"
  zone                           = "1"
  admin_username                 = "mysqlusern"
  admin_password                 = "ba5yatgfgfhdsvvc6A3ns2lu4gqzzc"
  sku_name                       = "GP_Standard_D8ds_v4"
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
