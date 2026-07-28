resource "azurerm_resource_group" "group_name" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

module "network" {
  source                  = "./modules/network"
  resource_group_name     = azurerm_resource_group.group_name.name
  resource_group_location = azurerm_resource_group.group_name.location
  network_name            = var.virtual_network_name
  v_net_address_prefix    = var.vnet_address_prefix
  subnet_name             = var.subnet_name
  subnet_address_prefix   = var.subnet_address_prefix
  pip_name                = var.public_ip_address_name
  dns_label               = var.dns_label
  network_SG_name         = var.network_security_group_name
  security_rules          = var.security_rules
}

module "compute" {
  source                  = "./modules/compute"
  resource_group_name     = azurerm_resource_group.group_name.name
  resource_group_location = azurerm_resource_group.group_name.location
  vm_name                 = var.vm_name
  vm_size                 = var.vm_size
  subnet_id               = module.network.subnet_id
  public_ip_id            = module.network.public_ip_id
  NSG_id                  = module.network.NSG_id
  extension_name          = "OnCreatingScript"
  path_to_script          = "oncreatingVM.sh"
  SSH_key                 = "sshkey"
  ssh_public_key_content  = var.ssh_key_public
}