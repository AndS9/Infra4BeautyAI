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
}