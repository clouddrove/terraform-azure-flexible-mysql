provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Flexible Mysql server module call.
##-----------------------------------------------------------------------------
module "flexible-mysql" {
  source                         = "../../"
  name                           = "app"
  environment                    = "test"
  resource_group_name            = "test-rg"
  location                       = "Central India"
  virtual_network_id             = "/subscriptions/---------------<vnet_id>---------------"
  delegated_subnet_id            = "/subscriptions/---------------<delegated_subnet_id>---------------"
  mysql_version                  = "8.0.21"
  private_dns                    = true
  enabled_user_assigned_identity = true
  zone                           = "1"
  database_names                 = ["database1", "database2"]
  administrator_login_name       = "sqladmin"
  admin_username                 = "mysqlusername"
  admin_password                 = "ba5yatgfgfhdsv6A3ns2lu4gqzzc"
  sku_name                       = "GP_Standard_D2ds_v4"
  auto_grow_enabled              = true
  ##server_configuration
  server_configuration_names = ["interactive_timeout", "audit_log_enabled"]
  values                     = ["600", "ON"]
}
