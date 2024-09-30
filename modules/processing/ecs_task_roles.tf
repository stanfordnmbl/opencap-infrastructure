### Exectuion role - permissions for ECS while spawning the tasks
data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "ecs-task-execution-role${var.env}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_execution_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = "${aws_iam_role.ecs_tasks_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

### Task tole - permissions for the running tasks
## Processing worker permissions
resource "aws_iam_role" "processing_worker_role" {
  name = "processing-worker-task-role${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_policy" "processing_worker_policy" {
  name        = "processing-worker-task-policy${var.env}"
  description = "Policy for ECS tasks to manage instance protection during Auto Scaling scale-in events and get CloudWatch metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetInstanceProtection",
          "autoscaling:DescribeAutoScalingInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "cloudwatch:GetMetricStatistics"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "processing_worker_policy_attachment" {
  name       = "processing-worker-task-policy-attachment${var.env}"
  roles      = [aws_iam_role.processing_worker_role.name]
  policy_arn = aws_iam_policy.processing_worker_policy.arn
}

## Celery (API) worker permissions

resource "aws_iam_role" "celery_worker_role" {
  name = "celery-worker-task-role${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_policy" "celery_worker_policy" {
  name        = "celery-worker-task-policy${var.env}"
  description = "Policy for Celery worker ECS task to submit CloudWatch metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "cloudwatch:PutMetricData"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "celery_worker_policy_attachment" {
  name       = "celery-worker-task-policy-attachment${var.env}"
  roles      = [aws_iam_role.celery_worker_role.name]
  policy_arn = aws_iam_policy.celery_worker_policy.arn
}
