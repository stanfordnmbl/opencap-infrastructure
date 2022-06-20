output "opencap-api-ecr-repository" {
  value = aws_ecr_repository.opencap-api.repository_url
}
output "opencap-ecr-repository" {
  value = aws_ecr_repository.opencap-opencap.repository_url
}
output "openpose-ecr-repository" {
  value = aws_ecr_repository.opencap-openpose.repository_url
}

output "db-endpoint" {
  value = aws_rds_cluster.default.endpoint
}
output "db-port" {
  value = aws_rds_cluster.default.port
}
output "db-name" {
  value = aws_rds_cluster.default.database_name
}
output "db-username" {
  value = aws_rds_cluster.default.master_username
  sensitive = true
}
output "db-password" {
  value = aws_rds_cluster.default.master_password
  sensitive = true
}