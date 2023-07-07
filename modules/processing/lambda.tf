variable "opencap_analysis_max_centerofmass_vpos_ecr_repository" {
  type        = string
  description = "Repository"
}

resource "aws_lambda_function" "analysis_max_centerofmass_vpos" {
  function_name = "analysis-max-centerofmass-vpos-${var.env}"
  timeout       = 500 # seconds
  image_uri     = "${var.opencap_analysis_max_centerofmass_vpos_ecr_repository}"
  package_type  = "Image"

  role = aws_iam_role.analysis_functions_execution_role.arn

  environment {
    variables = {
      ENVIRONMENT = var.env
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


resource "aws_iam_role" "analysis_functions_execution_role" {
  name = "analysis-functions-execution-role-${var.env}"

  assume_role_policy = jsonencode({
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
