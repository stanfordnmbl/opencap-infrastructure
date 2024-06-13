variable "env" {
  type        = string
  description = "Environment suffix"
  default     = ""
}
variable "region" {
  type        = string
  description = "Region"
  default     = "us-west-2"
}
variable "opencap_ecr_repository" {
  type        = string
  description = "Repository"
}
variable "openpose_ecr_repository" {
  type        = string
  description = "Repository"
}
variable "mmpose_ecr_repository" {
  type        = string
  description = "Repository"
}
variable "opencap_api_ecr_repository" {
  type        = string
  description = "Repository"
}
variable "api_host" {
  type        = string
  description = "Repository"
  default     = "api.opencap.ai"
}
variable "app_name" {
  type        = string
  description = "App name"
  default     = "opencap"
}
variable "num_machines" {
  type        = number
  description = "Number of machines"
  default     = 1
}

variable "processing_asg_scaling_config" {
  default = {
    min_size = 0
    max_size = 0
    desired_size = 0
  }
}

variable "processing_asg_scaling_target" {
  default = 5
  description = "How many trials-per-instance the autoscaling should attempt to maintain?"
}

variable "processing_asg_trials_baseline" {
  default = 0
  description = "How many trials the OnPremise infrastructure is capable of processing before autoscaling should kick in?"
}

variable "processing_asg_instance_type" {
  default = "g5.2xlarge"
}

variable "processing_ecs_task_memory" {
  description = <<-EOF
  We reserve 768 MiB for System & ECS agent. See `local.lt_user_data_raw`
  https://docs.aws.amazon.com/AmazonECS/latest/developerguide/memory-management.html
  While in reality there's less memory available, so we're using conservative values here
  https://github.com/aws/amazon-ecs-agent/issues/3331#issuecomment-1232664501
  Therefore memory value should be set accordingly to `var.processing_asg_instance_type`
  for g5.xlarge with 16GiB memory and 768MiB reservation AWS shows 15073 MiB registered
  for g5.2xlarge with 32GiB memory and 768MiB reservation = let's safely assume 15073*2 = 30146 MiB
  EOF
  default = 30146
}

variable "api_memory" {
  type        = number
  description = "Fargate API memory"
  default     = 16384
}
variable "api_cpu" {
  type        = number
  description = "Fargate API cpu"
  default     = 4096
}
variable "api_servers" {
  type        = number
  description = "Fargate num servers"
  default     = 2
}
variable "api_celery_memory" {
  type        = number
  description = "Fargate API celery memory"
  default     = 8192
}
variable "api_celery_cpu" {
  type        = number
  description = "Fargate API celery cpu"
  default     = 2048
}
variable "api_celery_beat_memory" {
  type        = number
  description = "Fargate API celery memory"
  default     = 512
}
variable "api_celery_beat_cpu" {
  type        = number
  description = "Fargate API celery cpu"
  default     = 256
}

variable "cidr" {
  type = map(string)
  default = {
    "" = "172.31.0.0/16"
    "-dev" = "172.39.0.0/16"
  }
}
variable "subnet_cidr" {
  type = map(string)
  default = {
    "" = "172.31.1.0/24"
    "-env" = "172.39.1.0/24"
  }
}
