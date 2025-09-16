output "eastus-rg" {
  value = azurerm_resource_group.eastus.name
}

output "eastus-location" {
  value = azurerm_resource_group.eastus.location
}

output "eastus-vnet-id" {
  value = module.eastus-net.vnet_id
}

output "eastus2-rg" {
  value = azurerm_resource_group.eastus2.name
}

output "eastus2-location" {
  value = azurerm_resource_group.eastus2.location
}

output "eastus2-vnet-id" {
  value = module.eastus2-net.vnet_id
}

output "westus-rg" {
  value = azurerm_resource_group.westus.name
}

output "westus-location" {
  value = azurerm_resource_group.westus.location
}

output "westus-vnet-id" {
  value = module.westus-net.vnet_id
}

output "mongodb_cluster_id" {
  description = "MongoDB Atlas cluster ID"
  value = module.mongodb-cluster.cluster_id
}

output "mongodb_connection_strings" {
  description = "MongoDB Atlas connection strings"
  value = module.mongodb-cluster.connection_strings
  sensitive = true
}

output "mongodb_private_endpoints" {
  description = "MongoDB Atlas private endpoint IDs"
  value = module.mongodb-cluster.private_endpoint_ids
}

output "mongodb_database_username" {
  description = "MongoDB database username for applications"
  value = module.mongodb-cluster.database_username
}

output "mongodb_app_connection_string" {
  description = "MongoDB connection string with application credentials"
  value = module.mongodb-cluster.database_connection_string
  sensitive = true
}

output "vnet_peering_status" {
  description = "VNet peering connection status"
  value = {
    peering_ids = module.network-peering.peering_ids
  }
}

# VM Outputs
output "eastus_vm_details" {
  description = "Details for East US VM"
  value = {
    public_ip = module.eastus-vm.public_ip_address
    private_ip = module.eastus-vm.private_ip_address
    ssh_command = module.eastus-vm.ssh_connection_command
    app_url = module.eastus-vm.app_url
  }
}

output "eastus2_vm_details" {
  description = "Details for East US2 VM"
  value = {
    public_ip = module.eastus2-vm.public_ip_address
    private_ip = module.eastus2-vm.private_ip_address
    ssh_command = module.eastus2-vm.ssh_connection_command
    app_url = module.eastus2-vm.app_url
  }
}

output "westus_vm_details" {
  description = "Details for West US VM"
  value = {
    public_ip = module.westus-vm.public_ip_address
    private_ip = module.westus-vm.private_ip_address
    ssh_command = module.westus-vm.ssh_connection_command
    app_url = module.westus-vm.app_url
  }
}