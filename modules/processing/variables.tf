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
variable "opencap_api_ecr_repository" {
  type        = string
  description = "Repository"
}
variable "num_machines" {
  type        = number
  description = "Number of machines"
  default     = 1
}


variable "cidr" {
  type = map(string)
  default = {
    "us-west-2" = "172.31.0.0/16"
    "us-west-1" = "172.39.0.0/16"
    "eu-west-1" = "172.35.0.0/16"
    "eu-central-1" = "172.36.0.0/16"
    "ap-northeast-1" = "172.37.0.0/16"
    "us-east-1" = "172.38.0.0/16"
  }
}
variable "subnet_cidr" {
  type = map(string)
  default = {
    "us-west-2" = "172.31.1.0/24"
    "us-west-1" = "172.39.1.0/24"
    "eu-west-1" = "172.35.1.0/24"
    "eu-central-1" = "172.36.1.0/24"
    "ap-northeast-1" = "172.37.1.0/24"
    "us-east-1" = "172.38.1.0/24"
  }
}
