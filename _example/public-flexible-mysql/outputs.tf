output "flexible-mysql_server_id" {
  value       = module.flexible-mysql.mysql_flexible_server_id
  description = "The ID of the MySQL Flexible Server."
}

output "azurerm_flexible-mysql_server_configuration_id" {
  value       = module.flexible-mysql.azurerm_mysql_flexible_server_configuration_id
  description = "The ID of the MySQL Flexible Server Configuration."
}

output "client_id" {
  value       = module.flexible-mysql.client_id
  description = "The ID of the app associated with the Identity."
}

output "tenant_id" {
  value       = module.flexible-mysql.tenant_id
  description = "The ID of the Tenant which the Identity belongs to."
}

output "public_network_access_enabled" {
  value       = module.flexible-mysql.public_network_access_enabled
  description = "Is the public network access enabled."
}

output "administrator_password" {
  value       = module.flexible-mysql.administrator_password
  sensitive   = true
  description = "The Password associated with the administrator_login for the MySQL Flexible Server. Required when create_mode is Default."
}
