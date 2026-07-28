output "vm_id" {
  value = azurerm_linux_virtual_machine.main.id
}
output "vm_public_ip_address" {
  value = azurerm_linux_virtual_machine.main.public_ip_address
}
