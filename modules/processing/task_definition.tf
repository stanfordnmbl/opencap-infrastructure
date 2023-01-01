resource "aws_cloudwatch_log_group" "logs" {
  name              = "/ecs/${var.app_name}-processing${var.env}"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "openpose-logs" {
  name              = "/ecs/${var.app_name}-openpose${var.env}"
  retention_in_days = 90
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "worker${var.env}"
  container_definitions = data.template_file.task_definition_template.rendered
  execution_role_arn    = aws_iam_role.ecs_tasks_execution_role.arn
  memory		= 7670
  volume {
    name      = "data${var.env}"
  }
}