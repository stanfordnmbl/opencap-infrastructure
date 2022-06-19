terraform {
  backend "s3" {
    bucket = "bsclight"
    key    = "terraform-us-west-2"
    region = "us-west-2"
    profile = "matterhorn"
  }
}