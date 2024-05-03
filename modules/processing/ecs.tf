resource "aws_ecs_cluster" "ecs_cluster" {
    name  = "${var.app_name}-processing-cluster${var.env}"
}

resource "aws_ecs_service" "worker" {
    name            = "worker"
    cluster         = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.task_definition.arn
    #   desired_count   = var.num_machines
    # Let auto-scaling manage the number of instances
    desired_count   = 0
    deployment_minimum_healthy_percent = 100

    capacity_provider_strategy {
        capacity_provider = aws_ecs_capacity_provider.worker_lt_gpu_provider.name
    }
}
