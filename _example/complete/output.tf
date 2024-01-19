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

output "ActiveDirectory_id" {
  value       = module.flexible-mysql.ActiveDirectory_id
  description = "The ID of the MySQL Flexible Server Active Directory Administrator."
}
