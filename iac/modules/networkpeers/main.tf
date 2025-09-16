resource "azurerm_virtual_network_peering" "peering" {
  count = length(var.peering_configs)

  name                      = var.peering_configs[count.index].name
  resource_group_name       = var.peering_configs[count.index].resource_group_name
  virtual_network_name      = var.peering_configs[count.index].virtual_network_name
  remote_virtual_network_id = var.peering_configs[count.index].remote_virtual_network_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}