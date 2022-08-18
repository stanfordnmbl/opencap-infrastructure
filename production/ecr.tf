resource "aws_ecr_repository" "opencap-opencap" {
  name                 = "opencap/opencap"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "opencap-openpose" {
  name                 = "opencap/openpose"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "opencap-mmpose" {
  name                 = "opencap/mmpose"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "opencap-api" {
  name                 = "opencap/api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}