output "subnet_ids" {
  value = "${values(aws_subnet.pub_subnet)}"
}
output "vpc_id" {
  value = [aws_subnet.pub_subnet]
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