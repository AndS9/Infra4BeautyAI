resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ip_config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.NSG_id
}

resource "azurerm_ssh_public_key" "example" {
  name                = var.SSH_key
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  public_key          = var.ssh_public_key_content
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = var.vm_name
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = var.vm_size

  admin_username                  = "developer"
  disable_password_authentication = true
  computer_name                   = "devHost"
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  identity {
    type = "SystemAssigned"
  }
  os_disk {
    name                 = "myosdisk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "developer"
    public_key = azurerm_ssh_public_key.example.public_key
  }
}

resource "azurerm_virtual_machine_extension" "startup" {
  depends_on           = [azurerm_virtual_machine_data_disk_attachment.dbattach]
  name                 = var.extension_name
  virtual_machine_id   = azurerm_linux_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = jsonencode({
    script = base64encode(file("${path.module}/../../${var.path_to_startscript}"))
  })
}

resource "azurerm_managed_disk" "dbdata" {
  lifecycle {
    prevent_destroy = true
  }
  name                 = "beautyAIdata"
  location             = var.resource_group_location
  resource_group_name  = var.resource_group_name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "8"
  zone                 = "1"

}
resource "azurerm_virtual_machine_data_disk_attachment" "dbattach" {
  managed_disk_id    = azurerm_managed_disk.dbdata.id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = "10"
  caching            = "ReadOnly"
}


data "azurerm_key_vault" "vault" {
  name                = var.secrets_vault_name
  resource_group_name = var.secrets_vault_rg
}
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = data.azurerm_key_vault.vault.id
  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_linux_virtual_machine.main.identity[0].principal_id
}