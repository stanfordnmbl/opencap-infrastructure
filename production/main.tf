module "processing" {
    region = "us-west-2"
    num_machines = 0
    opencap_ecr_repository = aws_ecr_repository.opencap-opencap.repository_url
    openpose_ecr_repository = aws_ecr_repository.opencap-openpose.repository_url
    opencap_api_ecr_repository = aws_ecr_repository.opencap-api.repository_url
    mmpose_ecr_repository = aws_ecr_repository.opencap-mmpose.repository_url
    # opencap_analysis_max_centerofmass_vpos_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap-analysis/max_centerofmass_vpos"
    
    source = "../modules/processing"
}
