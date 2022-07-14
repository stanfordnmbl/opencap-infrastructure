output "db-endpoint" {
  value = module.processing.db-endpoint
}
output "db-password" {
  value = module.processing.db-password
  sensitive = true
}
output "db-port" {
  value = module.processing.db-port
}
output "db-username" {
  value = module.processing.db-username
  sensitive = true
}
output "db-name" {
  value = module.processing.db-name
}
# output "db-port" {
#   value = aws_rds_cluster.default.port
# }
# output "db-name" {
#   value = aws_rds_cluster.default.database_name
# }
# output "db-username" {
#   value = aws_rds_cluster.default.master_username
#   sensitive = true
# }
# output "db-password" {
#   value = aws_rds_cluster.default.master_password
#   sensitive = true
# }