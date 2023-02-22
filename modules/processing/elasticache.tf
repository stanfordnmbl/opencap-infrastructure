resource "aws_elasticache_cluster" "redis_cache" {
  cluster_id           = "${var.app_name}-redis-cluster${var.env}"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
}
