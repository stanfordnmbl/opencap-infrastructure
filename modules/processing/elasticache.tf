resource "aws_elasticache_cluster" "redis_cache" {
  cluster_id           = "${var.app_name}-redis-cluster${var.env}"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  subnet_group_name = aws_elasticache_subnet_group.redis_subnet.name
}
