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
  location    = "Central India"
}

##-----------------------------------------------------------------------------
## Log Analytics module call.
##-----------------------------------------------------------------------------
module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "1.0.1"
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
}

##-----------------------------------------------------------------------------
## Flexible Mysql server module call.
##-----------------------------------------------------------------------------
module "flexible-mysql" {
  source                   = "../../"
  name                     = local.name
  environment              = local.environment
  resource_group_name      = module.resource_group.resource_group_name
  location                 = module.resource_group.resource_group_location
  mysql_version            = "8.0.21"
  zone                     = "1"
  administrator_login_name = "sqladmin"
  admin_username           = "mysqlusername"
  admin_password           = "ba5yatgfgfhdsv6A3ns2lu4gqzzc"
  sku_name                 = "GP_Standard_D2ds_v4"
  db_name                  = "maindb"
  charset                  = "utf8mb3"
  collation                = "utf8mb3_unicode_ci"
  enable_firewall_rule     = true
  auto_grow_enabled        = true
  iops                     = 360
  size_gb                  = "20"
  ##azurerm_mysql_flexible_server_configuration
  enable_diagnostic          = true
  server_configuration_names = ["interactive_timeout", "audit_log_enabled", "audit_log_events"]
  values                     = ["600", "ON", "CONNECTION,ADMIN,DDL,TABLE_ACCESS"]
  log_analytics_workspace_id = module.log-analytics.workspace_id
}
