variable "opencap_analysis_max_centerofmass_vpos_ecr_repository" {
  type        = string
  description = "Repository"
}

variable "opencap_gait_analysis_ecr_repository" {
  type        = string
  description = "Repository"
}

data "aws_secretsmanager_secret" "analysis_common_secrets" {
  arn = "arn:aws:secretsmanager:us-west-2:660440363484:secret:AnalysisFunctions${var.env}-TpGO1s"
}

data "aws_secretsmanager_secret_version" "analysis_common_secrets_version" {
  secret_id = data.aws_secretsmanager_secret.analysis_common_secrets.id
}

# Functions

# Analysis Max Center of Mass Vpos

resource "aws_lambda_function" "analysis_max_centerofmass_vpos" {
  function_name = "analysis-max-centerofmass-vpos${var.env}"
  timeout       = 900 # seconds
  image_uri     = "${var.opencap_analysis_max_centerofmass_vpos_ecr_repository}:latest"
  package_type  = "Image"
  memory_size = 1024

  role = aws_iam_role.analysis_functions_execution_role.arn

  environment {
    variables = {
      API_TOKEN = "${jsondecode(data.aws_secretsmanager_secret_version.analysis_common_secrets_version.secret_string)["api_token"]}"
      API_URL = "${jsondecode(data.aws_secretsmanager_secret_version.analysis_common_secrets_version.secret_string)["api_url"]}"
    }
  }
}


resource "aws_lambda_function_url" "analysis_max_centerofmass_vpos_url" {
  function_name      = aws_lambda_function.analysis_max_centerofmass_vpos.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

resource "aws_cloudwatch_log_group" "analysis_max_centerofmass_vpos_logs" {
  name              = "/aws/lambda/${aws_lambda_function.analysis_max_centerofmass_vpos.function_name}"
  retention_in_days = 90
}

# Gait analysis

resource "aws_lambda_function" "gait_analysis" {
  function_name = "gait-analysis${var.env}"
  timeout       = 900 # seconds
  image_uri     = "${var.opencap_gait_analysis_ecr_repository}:latest"
  package_type  = "Image"
  memory_size = 1024

  role = aws_iam_role.analysis_functions_execution_role.arn

  environment {
    variables = {
      API_TOKEN = "${jsondecode(data.aws_secretsmanager_secret_version.analysis_common_secrets_version.secret_string)["api_token"]}"
      API_URL = "${jsondecode(data.aws_secretsmanager_secret_version.analysis_common_secrets_version.secret_string)["api_url"]}"
    }
  }
}


resource "aws_lambda_function_url" "gait_analysis_url" {
  function_name      = aws_lambda_function.gait_analysis.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

resource "aws_cloudwatch_log_group" "gait_analysis_logs" {
  name              = "/aws/lambda/${aws_lambda_function.gait_analysis.function_name}"
  retention_in_days = 90
}

# IAM Role

resource "aws_iam_role" "analysis_functions_execution_role" {
  name = "analysis-functions-execution-role${var.env}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Policy

resource "aws_iam_policy" "analysis_functions_execution_policy" {
  name   = "analysis-functions-execution-policy${var.env}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "analysis_functions_execution_policy_attachment" {
  role = aws_iam_role.analysis_functions_execution_role.id
  policy_arn = aws_iam_policy.analysis_functions_execution_policy.arn
}
