# resource "aws_ecs_cluster" "cluster" {
#   name = "opencap-api-cluster"

#   setting {
#     name  = "containerInsights"
#     value = "disabled"
#   }
# }

# resource "aws_ecs_cluster_capacity_providers" "cluster" {
#   cluster_name = aws_ecs_cluster.cluster.name

#   capacity_providers = ["FARGATE_SPOT", "FARGATE"]

#   default_capacity_provider_strategy {
#     capacity_provider = "FARGATE_SPOT"
#   }
# }

# module "ecs-fargate" {
#   source = "umotif-public/ecs-fargate/aws"
#   version = "~> 6.1.0"

#   name_prefix        = "opencap-api"
#   vpc_id             = module.processing.vpc_id
#   private_subnet_ids = module.processing.subnet_ids

#   cluster_id         = aws_ecs_cluster.cluster.id

#   task_container_image   = aws_ecr_repository.opencap-api.repository_url
#   task_definition_cpu    = 256
#   task_definition_memory = 512

#   task_container_port             = 80
#   task_container_assign_public_ip = true

#   target_groups = [
#     {
#       target_group_name = "tg-opencap-api"
#       container_port    = 80
#     }
#   ]

#   health_check = {
#     port = "traffic-port"
#     path = "/"
#   }

#   tags = {
#     Environment = "test"
#     Project = "Test"
#   }
# }