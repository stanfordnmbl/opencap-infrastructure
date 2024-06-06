resource "aws_ecs_cluster" "ecs_cluster" {
  name  = "${var.app_name}-processing-cluster${var.env}"
}

resource "aws_ecs_cluster_capacity_providers" "default" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.worker_lt_gpu_provider.name,
  ]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.worker_lt_gpu_provider.name
  }
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
    weight = 100
  }

  lifecycle {
    ignore_changes = [
      desired_count,
    ]
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/ecs/${var.app_name}-processing${var.env}"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "openpose-logs" {
  name              = "/ecs/${var.app_name}-openpose${var.env}"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "mmpose-logs" {
  name              = "/ecs/${var.app_name}-mmpose${var.env}"
  retention_in_days = 90
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "worker${var.env}"
  container_definitions = data.template_file.task_definition_template.rendered
  execution_role_arn    = aws_iam_role.ecs_tasks_execution_role.arn
  task_role_arn         = aws_iam_role.processing_worker_role.arn
  # 31680(15840*2) should be the one to saturate g5.2xlarge
  # 15840 available for tasks on g5.xlarge
  memory                = 15840 # TODO might need to be adjusted to support bigger jobs/instances.
  # memory                = 31680 # TODO might need to be adjusted to support bigger jobs/instances.
  volume {
    name = "data${var.env}"
  }
}
