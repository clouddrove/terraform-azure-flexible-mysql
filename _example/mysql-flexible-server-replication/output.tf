output "flexible-mysql_server_id" {
  value       = module.flexible-mysql.mysql_flexible_server_id
  description = "The ID of the MySQL Flexible Server."
}

output "azurerm_private_dns_zone_virtual_network_link2_id" {
  value       = module.flexible-mysql.existing_private_dns_zone_virtual_network_link_id
  description = "The ID of the Private DNS Zone Virtual Network Link."
}

output "azurerm_flexible-mysql_server_configuration_id" {
  value       = module.flexible-mysql.azurerm_mysql_flexible_server_configuration_id
  description = "The ID of the MySQL Flexible Server Configuration."
}

output "administrator_password" {
  value       = module.flexible-mysql.administrator_password
  sensitive   = true
  description = "The Password associated with the administrator_login for the MySQL Flexible Server. Required when create_mode is Default."
}




