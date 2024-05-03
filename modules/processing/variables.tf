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

variable "processing_asg_use_launch_config" {
  default = true
  description =<<-EOF
  true: Use launch config for processing autoscaling group, false: use launch template
  This is for providing a smooth transition from launch config to launch template as LCs are deprecated
  the goal is to delete this variable along with LC code when all services are using launch templates
  EOF
}

variable "processing_asg_scaling_config" {
  default = {
    min_size = 0
    max_size = 0
    desired_size = 0
  }
}

variable "processing_asg_scaling_target" {
  default = 50
  description = "After how many opencap_trials_pending should the autoscaling kick in"
}

variable "processing_asg_instance_type" {
  default = "g5.xlarge"
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
