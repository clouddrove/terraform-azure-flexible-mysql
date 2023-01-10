output "mysql_flexible_server_id" {
  value       = module.mysql_flexible.mysql_flexible_server_id
  description = "The ID of the MySQL Flexible Server."
}
output "azurerm_private_dns_zone_virtual_network_link_id" {
  value       = module.mysql_flexible.azurerm_private_dns_zone_virtual_network_link_id
  description = "The ID of the Private DNS Zone Virtual Network Link."
}
output "azurerm_mysql_flexible_server_configuration_id" {
  value       = module.mysql_flexible.azurerm_mysql_flexible_server_configuration_id
  description = "The ID of the MySQL Flexible Server Configuration."
}

output "azurerm_private_dns_zone_id" {
  value       = module.mysql_flexible.azurerm_private_dns_zone_id
  description = "The Private DNS Zone ID."
}



