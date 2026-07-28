output "subnet_id" {
  value = azurerm_subnet.internal.id
}

output "public_ip_id" {
  value = azurerm_public_ip.mainIP.id
}
output "public_ip" {
  value = azurerm_public_ip.mainIP.ip_address
}
output "public_domain" {
  value = azurerm_public_ip.mainIP.domain_name_label
}
output "NSG_id" {
  value = azurerm_network_security_group.main.id
}