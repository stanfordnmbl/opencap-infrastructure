module "processing" {
    region = "us-west-1"
    num_machines = 0
    opencap_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap/opencap"
    openpose_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap/openpose"
    opencap_api_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap/api"
    env = "-dev"    
    
    source = "../modules/processing"
}
