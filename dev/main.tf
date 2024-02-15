module "processing" {
    region = "us-west-2"
    num_machines = 0
    opencap_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap/opencap"
    openpose_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap/openpose"
    opencap_api_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap/api-dev"
    mmpose_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap/mmpose"
    opencap_analysis_max_centerofmass_vpos_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap-analysis/max_centerofmass_vpos-dev"
    opencap_gait_analysis_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap-analysis/gait_analysis-dev"
    opencap_treadmill_gait_analysis_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap-analysis/treadmill_gait_analysis-dev"
    env = "-dev"
    api_host = "dev.opencap.ai"
    api_memory = 2048
    api_cpu = 1024
    api_servers = 1
    api_celery_memory = 1024
    api_celery_cpu = 512
    api_celery_beat_memory = 512
    api_celery_beat_cpu = 256
    
    source = "../modules/processing"
}
