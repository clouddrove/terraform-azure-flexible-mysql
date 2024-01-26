provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current_client_config" {}

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
  source                         = "../../"
  name                           = local.name
  environment                    = local.environment
  resource_group_name            = module.resource_group.resource_group_name
  location                       = module.resource_group.resource_group_location
  mysql_version                  = "8.0.21"
  zone                           = "1"
  administrator_login_name       = "sqladmin"
  admin_username                 = "mysqlusername"
  admin_password                 = "eI37N9pmiArUR31j"
  sku_name                       = "GP_Standard_D2ds_v4"
  database_names                 = ["database1", "database2"]
  enabled_user_assigned_identity = true
  enable_firewall_rule           = true
  start_ip_address               = "0.0.0.0"
  end_ip_address                 = "255.255.255.255"
  auto_grow_enabled              = true
  user_object_id = {
    "user1" = {
      object_id = data.azurerm_client_config.current_client_config.object_id
    },
  }
  #### enable diagnostic setting and server_configuration
  enable_diagnostic          = true
  server_configuration_names = ["interactive_timeout", "audit_log_enabled", "audit_log_events"]
  values                     = ["600", "ON", "CONNECTION,ADMIN,DDL,TABLE_ACCESS"]
  log_analytics_workspace_id = module.log-analytics.workspace_id
}
