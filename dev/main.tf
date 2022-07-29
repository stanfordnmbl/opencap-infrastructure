module "processing" {
    region = "us-west-2"
    num_machines = 0
    opencap_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap/opencap"
    openpose_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap/openpose"
    opencap_api_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap/api-dev"
    env = "-dev"
    api_host = "dev.opencap.ai"
    api_memory = 8192
    api_cpu = 4096
    api_servers = 1
    
    source = "../modules/processing"
}
