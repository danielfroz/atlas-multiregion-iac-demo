variable "env" {}
variable "location" {}
variable "vnet_address_space" {
  type = list(string)
  description = "same as azurerm_virtual_network.address_space"
}
variable "subnet_address_prefixes" {
  type = list(string)
  description = "same as azurerm_subnet.address_prefixes"
}
variable "resource_group" {}

