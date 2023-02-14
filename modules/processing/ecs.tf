resource "aws_ecs_cluster" "ecs_cluster" {
    name  = "${var.app_name}-processing-cluster${var.env}"
}

data "aws_sqs_queue" "queue_name" {
  name = "${var.app_name}-sqs${var.env}"
}

# Cloudwatch Logs
resource "aws_cloudwatch_log_stream" "task_backend_worker" {
  name           = "${var.app_name}-task-backend-worker${var.env}"
  log_group_name = aws_cloudwatch_log_group.task_backend.name
}

resource "aws_cloudwatch_log_stream" "task_backend_beat" {
  name           = "${var.app_name}-task-backend-worker${var.env}"
  log_group_name = aws_cloudwatch_log_group.task_backend.name
}

# Worker
resource "aws_ecs_task_definition" "task_backend_worker" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  family = "backend-worker"
  container_definitions = templatefile(
    "backend_container.json.tpl",
    merge(
      local.container_vars,
      {
        name       = "${var.app_name}-task-backend-worker${var.env}"
        command    = ["celery", "-A", "django_aws", "worker", "--loglevel", "info"]
        log_stream = aws_cloudwatch_log_stream.task_backend_worker.name
      },
    )
  )
  depends_on = [aws_sqs_queue.task, aws_db_instance.task]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.task_backend_task.arn
}

resource "aws_ecs_service" "task_backend_worker" {
  name                               = "${var.app_name}-task-backend-worker${var.env}"
  cluster                            = aws_ecs_cluster.task.id
  task_definition                    = aws_ecs_task_definition.task_backend_worker.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  enable_execute_command             = true

  network_configuration {
    security_groups  = [aws_security_group.task_ecs_backend.id]
    subnets          = [aws_subnet.task_private_1.id, aws_subnet.task_private_2.id]
    assign_public_ip = false
  }
}

# Beat
resource "aws_ecs_task_definition" "task_backend_beat" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  family = "backend-beat"
  container_definitions = templatefile(
    "backend_container.json.tpl",
    merge(
      local.container_vars,
      {
        name       = "${var.app_name}-task-backend-beat${var.env}"
        command    = ["celery", "-A", "django_aws", "beat", "--loglevel", "info"]
        log_stream = aws_cloudwatch_log_stream.task_backend_beat.name
      },
    )
  )
  depends_on = [aws_sqs_queue.task, aws_db_instance.task]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.task_backend_task.arn
}

resource "aws_ecs_service" "task_backend_beat" {
  name                               = "${var.app_name}-task-backend-beat${var.env}"
  cluster                            = aws_ecs_cluster.task.id
  task_definition                    = aws_ecs_task_definition.task_backend_beat.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  enable_execute_command             = true

  network_configuration {
    security_groups  = [aws_security_group.task_ecs_backend.id]
    subnets          = [aws_subnet.task_private_1.id, aws_subnet.task_private_2.id]
    assign_public_ip = false
  }
}