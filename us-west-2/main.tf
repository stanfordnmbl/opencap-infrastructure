module "processing" {
    region = "us-west-2"
    num_machines = 1
    opencap_ecr_repository = aws_ecr_repository.opencap-opencap.repository_url
    openpose_ecr_repository = aws_ecr_repository.opencap-openpose.repository_url
    
    source = "../modules/processing"
}
