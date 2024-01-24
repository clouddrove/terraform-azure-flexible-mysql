output "mysql_flexible_server_id" {
  value       = azurerm_mysql_flexible_server.main[*].id
  description = "The ID of the MySQL Flexible Server."
}

output "azurerm_private_dns_zone_virtual_network_link_id" {
  value       = azurerm_private_dns_zone_virtual_network_link.main[*].id
  description = "The ID of the Private DNS Zone Virtual Network Link."
}

output "existing_private_dns_zone_virtual_network_link_id" {
  value       = azurerm_private_dns_zone_virtual_network_link.main2[*].id
  description = "The ID of the Private DNS Zone Virtual Network Link."
}

output "azurerm_mysql_flexible_server_configuration_id" {
  value       = azurerm_mysql_flexible_server_configuration.main[*].id
  description = "The ID of the MySQL Flexible Server Configuration."
}

output "azurerm_private_dns_zone_id" {
  value       = azurerm_private_dns_zone.main[*].id
  description = "The Private DNS Zone ID."
}

output "client_id" {
  value       = azurerm_user_assigned_identity.example[0].client_id
  description = "The ID of the app associated with the Identity."
}

output "tenant_id" {
  value       = azurerm_user_assigned_identity.example[0].tenant_id
  description = "The ID of the app associated with the Identity."
}

output "ActiveDirectory_id" {
  value       = azurerm_mysql_flexible_server_active_directory_administrator.main[0].id
  description = "The ID of the MySQL Flexible Server Active Directory Administrator."
}

output "server_fqdn" {
  value       = azurerm_mysql_flexible_server.main[0].fqdn
  description = "The fully qualified domain name of the MySQL Flexible Server."
}

output "public_network_access_enabled" {
  value       = azurerm_mysql_flexible_server.main[0].public_network_access_enabled
  description = "Is the public network access enabled."
}
