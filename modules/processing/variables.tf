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
variable "api_host" {
  type        = string
  description = "Repository"
  default     = "api.opencap.ai"
}
variable "num_machines" {
  type        = number
  description = "Number of machines"
  default     = 1
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
