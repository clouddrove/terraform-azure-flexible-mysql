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

output "ActiveDirectory_id" {
  value       = module.flexible-mysql.ActiveDirectory_id
  description = "The ID of the MySQL Flexible Server Active Directory Administrator."
}

output "public_network_access_enabled" {
  value       = module.flexible-mysql.public_network_access_enabled
  description = "Is the public network access enabled."
}
