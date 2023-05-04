provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.2"

  name        = "app-mysqll"
  environment = "test"
  label_order = ["name", "environment"]
  location    = "Canada Central"
}

module "vnet" {
  source              = "clouddrove/vnet/azure"
  version             = "1.0.1"
  name                = "app"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
  enable_ddos_pp      = false
}

module "subnet" {
  source               = "clouddrove/subnet/azure"
  version              = "1.0.2"
  name                 = "app"
  environment          = "test"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet.vnet_name)

  #subnet
  default_name_subnet = true
  subnet_names        = ["default"]
  subnet_prefixes     = ["10.0.1.0/24"]
  service_endpoints   = ["Microsoft.Storage"]
  delegation = {
    flexibleServers_delegation = [
      {
        name    = "Microsoft.DBforMySQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    ]
  }
}



module "flexible-mysql" {
  depends_on          = [module.resource_group, module.vnet]
  source              = "../.."
  name                = "app"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  virtual_network_id  = module.vnet.vnet_id[0]
  delegated_subnet_id = module.subnet.default_subnet_id[0]
  mysql_version       = "8.0.21"
  mysql_server_name   = "testmysqlserver"
  private_dns         = true
  zone                = "1"
  admin_username      = "mysqlusername"
  admin_password      = "ba5yatgfgfhdsv6A3ns2lu4gqzzc"
  sku_name            = "GP_Standard_D8ds_v4"
  db_name             = "maindb"
  charset             = "utf8mb3"
  collation           = "utf8mb3_unicode_ci"
  auto_grow_enabled   = true
  iops                = 360
  size_gb             = "20"

  ##azurerm_mysql_flexible_server_configuration
  server_configuration_names = ["interactive_timeout", "audit_log_enabled"]
  values                     = ["600", "ON"]

}
