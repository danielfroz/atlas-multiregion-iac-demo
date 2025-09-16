variable env {}

variable project_id {
  description = "MongoDB Atlas Project Id"
  type = string
}

variable cluster_type {
  description = "Type of cluster"
  type = string
  default = "REPLICASET"
}

variable "region_configs" {
  description = "List of region configurations for the cluster"
  type = list(object({
    provider_name = string
    region_name = string
    priority = number
    instance_size = string
    node_count = number
  }))
}

variable "vnet_configs" {
  description = "List of VNet configurations for private link"
  type = list(object({
    vnet_id = string
    subnet_id = string
    resource_group_name = string
    region = string
  }))
  default = []
}

variable "enable_online_archive" {
  description = "Enable online archive for the cluster"
  type = bool
  default = false
}

variable "database_username" {
  description = "Database username for application access"
  type = string
  default = "app"
}

variable "database_password" {
  description = "Database password for application access"
  type = string
  default = "ChangeMe123!"
  sensitive = true
}