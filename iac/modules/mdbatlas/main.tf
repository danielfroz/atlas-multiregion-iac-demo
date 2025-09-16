resource "mongodbatlas_advanced_cluster" "cluster" {
  project_id = var.project_id
  name = var.env
  cluster_type = var.cluster_type

  replication_specs {
    dynamic "region_configs" {
      for_each = var.region_configs
      content {
        electable_specs {
          instance_size = region_configs.value.instance_size
          node_count = region_configs.value.node_count
        }
        provider_name = region_configs.value.provider_name
        priority = region_configs.value.priority
        region_name = region_configs.value.region_name
      }
    }
  }

  backup_enabled = false
  pit_enabled = false
}

resource "mongodbatlas_privatelink_endpoint" "endpoints" {
  count = length(var.vnet_configs)
  project_id = var.project_id
  provider_name = var.region_configs[count.index].provider_name
  region = var.vnet_configs[count.index].region
}

resource "azurerm_private_endpoint" "mongodb_endpoints" {
  count = length(var.vnet_configs)
  name = "${var.env}-mongodb-pe-${lower(var.vnet_configs[count.index].region)}"
  location = var.vnet_configs[count.index].region
  resource_group_name = var.vnet_configs[count.index].resource_group_name
  subnet_id = var.vnet_configs[count.index].subnet_id

  private_service_connection {
    name = mongodbatlas_privatelink_endpoint.endpoints[count.index].private_link_service_name
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.endpoints[count.index].private_link_service_resource_id
    is_manual_connection = true
    request_message = "MongoDB Atlas Private Link"
  }
}

resource "mongodbatlas_privatelink_endpoint_service" "endpoint_service" {
  count = length(var.vnet_configs)
  provider_name = "AZURE"
  project_id = var.project_id
  private_link_id = mongodbatlas_privatelink_endpoint.endpoints[count.index].private_link_id
  endpoint_service_id = azurerm_private_endpoint.mongodb_endpoints[count.index].id
  private_endpoint_ip_address = azurerm_private_endpoint.mongodb_endpoints[count.index].private_service_connection[0].private_ip_address
}

resource "mongodbatlas_database_user" "app_user" {
  username           = var.database_username
  password           = var.database_password
  project_id         = var.project_id
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}

resource "mongodbatlas_online_archive" "archive" {
  count = var.enable_online_archive ? 1 : 0
  project_id = var.project_id
  cluster_name = mongodbatlas_advanced_cluster.cluster.name
  db_name = "account"
  coll_name = "contracts"

  data_process_region {
    cloud_provider = "AZURE"
    region = "US_EAST_2"
  }

  criteria {
    type = "DATE"
    date_field = "created"
    date_format = "ISODATE"
    expire_after_days = 30
  }

  partition_fields {
    field_name = "tid"
    order = 0
  }
  
  partition_fields {
    field_name = "created"
    order = 1
  }

  partition_fields {
    field_name = "year"
    order = 2
  }
}