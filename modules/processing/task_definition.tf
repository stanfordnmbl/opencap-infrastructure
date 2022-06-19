resource "aws_cloudwatch_log_group" "logs" {
  name              = "/ecs/br"
  retention_in_days = 90
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "worker"
  container_definitions = data.template_file.task_definition_template.rendered
  task_role_arn         = "arn:aws:iam::254015635887:role/ecsTaskExecutionRole"
  execution_role_arn         = "arn:aws:iam::254015635887:role/ecsTaskExecutionRole"
  memory		= 7670
  volume {
    name      = "ipc"
  }
}