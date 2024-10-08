resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-api-cluster${var.env}"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_service" "api" {
  name            = "api-server${var.env}"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_opencap_api.arn
  desired_count   = var.api_servers
  deployment_minimum_healthy_percent = 0
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 100
  }
  network_configuration {
    subnets = [aws_subnet.pub_subnet.0.id, aws_subnet.pub_subnet.1.id, aws_subnet.pub_subnet.2.id, aws_subnet.pub_subnet.3.id]
    security_groups = [aws_security_group.ecs_sg.id, aws_security_group.api_sg.id, aws_vpc.vpc.default_security_group_id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.opencap-api.arn
    container_name   = "code"
    container_port   = 80
  }  
}

resource "aws_ecs_service" "api-celery" {
  name            = "api-server-celery${var.env}"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_opencap_api_celery.arn
  desired_count   = 1
  deployment_minimum_healthy_percent = 0
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 100
  }
  network_configuration {
    subnets = [aws_subnet.pub_subnet.0.id, aws_subnet.pub_subnet.1.id, aws_subnet.pub_subnet.2.id, aws_subnet.pub_subnet.3.id]
    security_groups = [aws_security_group.ecs_sg.id, aws_security_group.api_sg.id, aws_vpc.vpc.default_security_group_id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "api-celery-beat" {
  name            = "api-server-celery-beat${var.env}"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_opencap_api_celery_beat.arn
  desired_count   = 1
  deployment_minimum_healthy_percent = 0
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 100
  }
  network_configuration {
    subnets = [aws_subnet.pub_subnet.0.id, aws_subnet.pub_subnet.1.id, aws_subnet.pub_subnet.2.id, aws_subnet.pub_subnet.3.id]
    security_groups = [aws_security_group.ecs_sg.id, aws_security_group.api_sg.id, aws_vpc.vpc.default_security_group_id]
    assign_public_ip = true
  }
}

resource "aws_cloudwatch_log_group" "api-logs" {
  name              = "/ecs/${var.app_name}-api${var.env}"
  retention_in_days = 90
}

locals {
    opencap_api_template_common_context = {
        REGION = "${var.region}"
        ENV = "${var.env}"
        OPENCAP_API = "${var.opencap_api_ecr_repository}"
        API_HOST = "${var.api_host}"
        APP_NAME = "${var.app_name}"
        API_TOKEN = var.env == "-dev" ? "arn:aws:secretsmanager:us-west-2:660440363484:secret:APICredentials-Dag8bw:api_token_dev::" : "arn:aws:secretsmanager:us-west-2:660440363484:secret:APICredentials-Dag8bw:api_token::"
        API_AWS_KEY = "arn:aws:secretsmanager:us-west-2:660440363484:secret:APICredentials-Dag8bw:aws_access_key_id::"
        API_AWS_SECRET = "arn:aws:secretsmanager:us-west-2:660440363484:secret:APICredentials-Dag8bw:aws_secret_access_key::"
        SENDGRID_API_KEY = "arn:aws:secretsmanager:us-west-2:660440363484:secret:APICredentials-Dag8bw:sendgrid_api_key::"
        SENTRY_DSN = var.env == "-dev" ? "arn:aws:secretsmanager:us-west-2:660440363484:secret:APICredentials-Dag8bw:sentry_dsn_dev::" : "arn:aws:secretsmanager:us-west-2:660440363484:secret:APICredentials-Dag8bw:sentry_dsn::"
        # SENTRY_DSN = "arn:aws:secretsmanager:us-west-2:660440363484:secret:APICredentials-Dag8bw:sentry_dsn::"
        DB_HOST = aws_rds_cluster.default.endpoint
        DB_USER_ARN = "${data.aws_secretsmanager_secret.secretmasterDB.arn}:username::"
        DB_PASS_ARN = "${data.aws_secretsmanager_secret.secretmasterDB.arn}:password::"
        REDIS_URL = "redis://${aws_elasticache_cluster.redis_cache.cache_nodes.0.address}:${aws_elasticache_cluster.redis_cache.cache_nodes.0.port}"
        DEBUG = var.env == "-dev" ? "True" : "False"
        CMD = ""
    }
}


data "template_file" "opencap_api_template" {
    template = file("../modules/processing/task_api.json.tpl")
    vars = merge(local.opencap_api_template_common_context, {
        CMD = join(",", ["uwsgi", "--show-config"])
    })
}

data "template_file" "opencap_api_celery_template" {
    template = file("../modules/processing/task_api.json.tpl")
    vars = merge(local.opencap_api_template_common_context, {
        CMD = join(",", ["celery", "-A", "mcserver", "worker", "--loglevel", "info"])
    })
}

data "template_file" "opencap_api_celery_beat_template" {
    template = file("../modules/processing/task_api.json.tpl")
    vars = merge(local.opencap_api_template_common_context, {
        CMD = join(",", ["celery", "-A", "mcserver", "beat", "--loglevel", "info"])
    })
}



resource "aws_ecs_task_definition" "task_opencap_api" {
  network_mode          = "awsvpc"
  family                = "${var.app_name}-api${var.env}"
  container_definitions = data.template_file.opencap_api_template.rendered
  execution_role_arn    = aws_iam_role.ecs_tasks_execution_role.arn
  memory                = var.api_memory
  cpu                   = var.api_cpu
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_task_definition" "task_opencap_api_celery" {
  network_mode          = "awsvpc"
  family                = "${var.app_name}-api-worker${var.env}"
  container_definitions = data.template_file.opencap_api_celery_template.rendered
  execution_role_arn    = aws_iam_role.ecs_tasks_execution_role.arn
  task_role_arn         = aws_iam_role.celery_worker_role.arn
  memory                = var.api_celery_memory
  cpu                   = var.api_celery_cpu
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_task_definition" "task_opencap_api_celery_beat" {
  network_mode          = "awsvpc"
  family                = "${var.app_name}-api-beat${var.env}"
  container_definitions = data.template_file.opencap_api_celery_beat_template.rendered
  execution_role_arn    = aws_iam_role.ecs_tasks_execution_role.arn
  memory                = var.api_celery_beat_memory
  cpu                   = var.api_celery_beat_cpu
  requires_compatibilities = ["FARGATE"]
}


resource "aws_lb" "opencap-api" {
  name               = "${var.app_name}-api${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id, aws_security_group.api_sg.id, aws_vpc.vpc.default_security_group_id]
  subnets            = [aws_subnet.pub_subnet.0.id, aws_subnet.pub_subnet.1.id, aws_subnet.pub_subnet.2.id, aws_subnet.pub_subnet.3.id]
 
  enable_deletion_protection = false
  idle_timeout = 4000
}
 
resource "aws_alb_target_group" "opencap-api" {
  name        = "${var.app_name}-api${var.env}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   unhealthy_threshold = "2"
   path              = "/health/"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.opencap-api.id
  port              = 80
  protocol          = "HTTP"
 
  default_action {
   type = "redirect"
 
   redirect {
     port        = 443
     protocol    = "HTTPS"
     status_code = "HTTP_301"
   }
  }
}
 
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.opencap-api.id
  port              = 443
  protocol          = "HTTPS"
 
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-west-2:660440363484:certificate/8add0853-64ea-4bed-8458-f40bf12cbd60"
#  "arn:aws:acm:us-west-2:660440363484:certificate/94bf7dd8-3d86-420f-9086-f976d17afef1"
 
  default_action {
    target_group_arn = aws_alb_target_group.opencap-api.id
    type             = "forward"
  }
}
