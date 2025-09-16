output "peering_ids" {
  description = "IDs of the created VNet peerings"
  value = azurerm_virtual_network_peering.peering[*].id
}