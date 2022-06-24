resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "opencap-db-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
  publicly_accessible = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
}
resource "aws_rds_cluster" "default" {
  cluster_identifier = "opencap-db-cluster"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  database_name      = "opencap"
  master_username    = local.db_creds.username
  master_password    = local.db_creds.password
  engine             = "aurora-postgresql"
  storage_encrypted  = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
}