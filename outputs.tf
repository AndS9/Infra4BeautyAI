output "resource_group" {
  value = azurerm_resource_group.group_name
}
output "location" {
  value = azurerm_resource_group.group_name
}

output "public_ip" {
  value = module.network.public_ip
}
output "public_domain" {
  value = module.network.public_domain
}

