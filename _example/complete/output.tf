output "flexible-mysql_server_id" {
  value       = module.flexible-mysql.mysql_flexible_server_id
  description = "The ID of the MySQL Flexible Server."
}

output "azurerm_private_dns_zone_virtual_network_link_id" {
  value       = module.flexible-mysql.azurerm_private_dns_zone_virtual_network_link_id
  description = "The ID of the Private DNS Zone Virtual Network Link."
}

output "azurerm_flexible-mysql_server_configuration_id" {
  value       = module.flexible-mysql.azurerm_mysql_flexible_server_configuration_id
  description = "The ID of the MySQL Flexible Server Configuration."
}

output "azurerm_private_dns_zone_id" {
  value       = module.flexible-mysql.azurerm_private_dns_zone_id
  description = "The Private DNS Zone ID."
}

output "client_id" {
  value       = module.flexible-mysql.client_id
  description = "The ID of the app associated with the Identity."
}

output "tenant_id" {
  value       = module.flexible-mysql.tenant_id
  description = "The ID of the Tenant which the Identity belongs to."
}

output "server_fqdn" {
  value       = module.flexible-mysql.server_fqdn
  description = "The fully qualified domain name of the MySQL Flexible Server."
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
