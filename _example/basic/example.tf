provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Flexible Mysql server module call.
##-----------------------------------------------------------------------------
module "flexible-mysql" {
  source              = "../../"
  name                = "app"
  environment         = "test"
  resource_group_name = "test-rg"
  location            = "Central India"
  virtual_network_id  = "/subscriptions/---------------<vnet_id>---------------"
  delegated_subnet_id = "/subscriptions/---------------<delegated_subnet_id>---------------"
  mysql_version       = "8.0.21"
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
