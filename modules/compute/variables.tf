variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group"
  type        = string
}

variable "vm_name" {
  description = "Virtual Machine Name"
  type        = string
  default     = "matebox"
}
variable "vm_size" {
  description = "Size of VM"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "subnet_id" {
  type = string
}

variable "public_ip_id" {
  type = string
}

variable "NSG_id" {
  type = string
}

variable "extension_name" {
  type    = string
  default = "CustomScript"
}

variable "path_to_startscript" {
  type = string
}
variable "SSH_key" {
  type    = string
  default = "linuxboxsshkey"
}

variable "ssh_public_key_content" {
  type = string
}

variable "secrets_vault_name_adm" {
  type    = string
  default = "secretval"
}

variable "secrets_vault_name_app" {
  type    = string
  default = "secretval"
}

variable "secrets_vault_rg" {
  type = string
}