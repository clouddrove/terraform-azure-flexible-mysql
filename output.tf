output "mysql_flexible_server_id" {
  value       = join("", azurerm_mysql_flexible_server.main.*.id)
  description = "The ID of the MySQL Flexible Server."
}

output "azurerm_private_dns_zone_virtual_network_link_id" {
  value       = join("", azurerm_private_dns_zone_virtual_network_link.main.*.id)
  description = "The ID of the Private DNS Zone Virtual Network Link."
}
output "existing_private_dns_zone_virtual_network_link_id" {
  value       = join("", azurerm_private_dns_zone_virtual_network_link.main2.*.id)
  description = "The ID of the Private DNS Zone Virtual Network Link."
}
output "azurerm_mysql_flexible_server_configuration_id" {
  value       = join("", azurerm_mysql_flexible_server_configuration.main.*.id)
  description = "The ID of the MySQL Flexible Server Configuration."
}
output "azurerm_private_dns_zone_id" {
  value       = join("", azurerm_private_dns_zone.main.*.id)
  description = "The Private DNS Zone ID."
}

output "password_result" {
  value = var.admin_password == null ? random_password.main[0].result : var.admin_password
  description = "Password Value"
  sensitive = true
}





