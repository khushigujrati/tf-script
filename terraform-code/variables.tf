variable "resource_group_name" {
  type        = string
  description = "Resource group name in Azure"
}
variable "location" {
  type        = string
  description = "Resources location in Azure"
}
variable "vnet_name" {
  type        = string
  description = "Virtual Network name"
}
variable "subnet_name" {
  type        = string
  description = "Subnet name"
}
variable "pip_name" {
  type        = string
  description = "Public IP address name"
}
variable "nsg_name" {
  type        = string
  description = "Network security group name"
}
variable "nic_name" {
  type        = string
  description = "Network interface name"
}
variable "storageaccount_name" {
  type        = string
  description = "Storage account name"
}
variable "vm_name" {
  type        = string
  description = "Virtual Machine name in Azure"
}
variable "cluster_name" {
  type        = string
  description = "AKS name in Azure"
}
variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
}
variable "acr_name" {
  type        = string
  description = "ACR name"
}
variable "vm_username" {
  type        = string
  description = "Username for the VM"
}
variable "vm_password" {
  type        = string
  description = "Password for the VM"
}
variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics"
  default     = "Standard_LRS"
}
