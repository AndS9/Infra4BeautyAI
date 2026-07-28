# COMMON VARIABLES
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "example-resource-group"
}

variable "resource_group_location" {
  description = "The location of the resource group"
  type        = string
}
#______________________________________________________________________________|

# NETWORK's VARIABLES
variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet"
}
variable "vnet_address_prefix" {
  description = "Virtual network address prefix"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "default"
}

variable "subnet_address_prefix" {
  description = "Subnet address prefix"
  type        = list(string)
  default     = ["10.0.0.0/24"]
}
variable "public_ip_address_name" {
  description = "Name of the puplic ip resource"
  type        = string
  default     = "publicIP"
}
variable "dns_label" {
  description = "DNS for service"
  type        = string
  default     = "domain_name"
}
variable "network_security_group_name" {
  description = "Name of Network Security Group"
  type        = string
  default     = "defaultnsg"
}

variable "security_rules" {
  description = "List of security rules for the network security group"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "SSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTP-app"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8000"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}
#______________________________________________________________________________|

# VIRTUAL MACHINE VARIABLES
variable "vm_name" {
  description = "Virtual Machine Name"
  type        = string
  default     = "testVM"
}
variable "vm_size" {
  description = "Size of VM"
  type        = string
  default     = "Standard_B1s"
}
variable "ssh_key_public" {
  type    = string
  default = "your-public-key-content"
}
#______________________________________________________________________________|