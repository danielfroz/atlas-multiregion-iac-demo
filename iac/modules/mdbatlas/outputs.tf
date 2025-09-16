output "cluster_id" {
  description = "The cluster ID"
  value = mongodbatlas_advanced_cluster.cluster.cluster_id
}

output "cluster_name" {
  description = "The cluster name"
  value = mongodbatlas_advanced_cluster.cluster.name
}

output "connection_strings" {
  description = "Set of connection strings that your applications can use to connect to this cluster"
  value = mongodbatlas_advanced_cluster.cluster.connection_strings
}

output "private_endpoint_ids" {
  description = "List of private endpoint IDs"
  value = azurerm_private_endpoint.mongodb_endpoints[*].id
}

output "online_archive_id" {
  description = "The online archive ID"
  value = var.enable_online_archive ? mongodbatlas_online_archive.archive[0].archive_id : null
}

output "database_username" {
  description = "Database username for application access"
  value = mongodbatlas_database_user.app_user.username
}

output "database_connection_string" {
  description = "MongoDB connection string with credentials"
  value = replace(
    mongodbatlas_advanced_cluster.cluster.connection_strings[0].standard_srv,
    "mongodb+srv://",
    "mongodb+srv://${mongodbatlas_database_user.app_user.username}:${mongodbatlas_database_user.app_user.password}@"
  )
  sensitive = true
}