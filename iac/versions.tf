terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=4.44.0"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "=1.41.0"
    }
  }
}