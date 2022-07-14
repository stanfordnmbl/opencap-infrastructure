resource "aws_ecs_cluster" "ecs_cluster" {
    name  = "opencap-processing-cluster${var.env}"
}