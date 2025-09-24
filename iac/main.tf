provider "azurerm" {
  features {}
  # subscription_id, tenant_id and service principal credentials comes from the ENV VARIABLES
}

provider "mongodbatlas" {
}

locals {
  env = "prd"
}

resource "azurerm_resource_group" "eastus" {
  name = "${local.env}-eastus-rg"
  location = "eastus"
}

resource "azurerm_resource_group" "eastus2" {
  name = "${local.env}-eastus2-rg"
  location = "eastus2"
}

resource "azurerm_resource_group" "westus" {
  name = "${local.env}-westus-rg"
  location = "westus"
}

# 
# /24 vnet is a such small network! Change it to /16, then provision the subnets.
# Since this demo is only concerning 1 VM + Atlas, then it serves us well.
# The best way really is to define rg and vnets to their base terraform project and then reference it everywhere.
# 
# We may want to utilize the following subnets for each region:
# eastus
# - 10.0.0.0/24 (prod)
# - 10.0.1.0/24 (staging)
# - 10.0.2.0/24 (qa)
# - 10.0.2.0/24 (dev)
# eastus2
# - 10.1.0.0/24 (prod)
# - 10.1.1.0/24 (staging)
# ...
module "eastus-net" {
  source = "./modules/network"
  env = local.env
  location = azurerm_resource_group.eastus.location
  resource_group = azurerm_resource_group.eastus.name
  vnet_address_space = [ "10.0.0.0/24" ]
  subnet_address_prefixes = [ "10.0.0.0/24" ]
}
module "eastus2-net" {
  source = "./modules/network"
  env = local.env
  location = azurerm_resource_group.eastus2.location
  resource_group = azurerm_resource_group.eastus2.name
  vnet_address_space = [ "10.1.0.0/24" ]
  subnet_address_prefixes = [ "10.1.0.0/24" ]
}
module "westus-net" {
  source = "./modules/network"
  env = local.env
  location = azurerm_resource_group.westus.location
  resource_group = azurerm_resource_group.westus.name
  vnet_address_space = [ "10.2.0.0/24" ]
  subnet_address_prefixes = [ "10.2.0.0/24" ]
}

module "network-peering" {
  source = "./modules/networkpeers"
  peering_configs = [
    {
      name                      = "${local.env}-eastus-to-eastus2"
      resource_group_name       = azurerm_resource_group.eastus.name
      virtual_network_name      = module.eastus-net.vnet_name
      remote_virtual_network_id = module.eastus2-net.vnet_id
    },
    {
      name                      = "${local.env}-eastus2-to-eastus"
      resource_group_name       = azurerm_resource_group.eastus2.name
      virtual_network_name      = module.eastus2-net.vnet_name
      remote_virtual_network_id = module.eastus-net.vnet_id
    },
    {
      name                      = "${local.env}-eastus-to-westus"
      resource_group_name       = azurerm_resource_group.eastus.name
      virtual_network_name      = module.eastus-net.vnet_name
      remote_virtual_network_id = module.westus-net.vnet_id
    },
    {
      name                      = "${local.env}-westus-to-eastus"
      resource_group_name       = azurerm_resource_group.westus.name
      virtual_network_name      = module.westus-net.vnet_name
      remote_virtual_network_id = module.eastus-net.vnet_id
    },
    {
      name                      = "${local.env}-eastus2-to-westus"
      resource_group_name       = azurerm_resource_group.eastus2.name
      virtual_network_name      = module.eastus2-net.vnet_name
      remote_virtual_network_id = module.westus-net.vnet_id
    },
    {
      name                      = "${local.env}-westus-to-eastus2"
      resource_group_name       = azurerm_resource_group.westus.name
      virtual_network_name      = module.westus-net.vnet_name
      remote_virtual_network_id = module.eastus2-net.vnet_id
    }
  ]
}

resource "mongodbatlas_organization" "imported" {
  name = "Demo"
}

#
# Change this value
# 
# Create this Demo organization at your Atlas account
# Go to organization settings, then Create New Organization
# In Access Manager, Projects, you will see the Org Id from the URL (https://cloud.mongodb.com/v2#/org/ORG_ID/projects)
#
import {
  id = "68d353b4312ac1308626fe82"
  to = mongodbatlas_organization.imported
}

resource "mongodbatlas_project" "project" {
  name = local.env
  org_id = mongodbatlas_organization.imported.org_id
  project_owner_id = mongodbatlas_organization.imported.org_owner_id
  tags = {
    environment = local.env
  }
}

module "mongodb-cluster" {
  source = "./modules/mdbatlas"
  project_id = mongodbatlas_project.project.id
  env = local.env
  enable_online_archive = true
  region_configs = [
    {
      provider_name = "AZURE"
      region_name = "US_EAST_2"
      priority = 7
      instance_size = "M10"
      node_count = 2
    },
    {
      provider_name = "AZURE"
      region_name = "US_EAST"
      priority = 6
      instance_size = "M10"
      node_count = 2
    },
    {
      provider_name = "AZURE"
      region_name = "US_WEST"
      priority = 5
      instance_size = "M10"
      node_count = 1
    }
  ]
  vnet_configs = [
    {
      vnet_id = module.eastus-net.vnet_id
      subnet_id = module.eastus-net.subnet_id
      resource_group_name = module.eastus-net.resource_group_name
      region = azurerm_resource_group.eastus.location
    },
    {
      vnet_id = module.eastus2-net.vnet_id
      subnet_id = module.eastus2-net.subnet_id
      resource_group_name = module.eastus2-net.resource_group_name
      region = azurerm_resource_group.eastus2.location
    },
    {
      vnet_id = module.westus-net.vnet_id
      subnet_id = module.westus-net.subnet_id
      resource_group_name = module.westus-net.resource_group_name
      region = azurerm_resource_group.westus.location
    }
  ]
}

module "eastus2-vm" {
  source = "./modules/vm"
  env = local.env
  location = azurerm_resource_group.eastus2.location
  resource_group_name = azurerm_resource_group.eastus2.name
  subnet_id = module.eastus2-net.subnet_id
  vm_name = "${local.env}-eastus2-vm"
  vm_size = "Standard_B1s"
  admin_username = "azureuser"
  admin_password = "ChangeMe123!"
  tags = {
    environment = local.env
    region = azurerm_resource_group.eastus2.location
  }
}

module "eastus-vm" {
  source = "./modules/vm"
  env = local.env
  location = azurerm_resource_group.eastus.location
  resource_group_name = azurerm_resource_group.eastus.name
  subnet_id = module.eastus-net.subnet_id
  vm_name = "${local.env}-eastus-vm"
  vm_size = "Standard_B1s"
  admin_username = "azureuser"
  admin_password = "ChangeMe123!"
  tags = {
    environment = local.env
    region = azurerm_resource_group.eastus.location
  }
}

module "westus-vm" {
  source = "./modules/vm"
  env = local.env
  location = azurerm_resource_group.westus.location
  resource_group_name = azurerm_resource_group.westus.name
  subnet_id = module.westus-net.subnet_id
  vm_name = "${local.env}-westus-vm"
  vm_size = "Standard_B1s"
  admin_username = "azureuser"
  admin_password = "ChangeMe123!"
  tags = {
    environment = local.env
    region = azurerm_resource_group.westus.location
  }
}