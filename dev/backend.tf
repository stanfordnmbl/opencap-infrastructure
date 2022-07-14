terraform {
  backend "s3" {
    bucket = "opencap-infra-dev"
    key    = "terraform-us-west-2"
    region = "us-west-2"
    profile = "mobilize"
  }
}