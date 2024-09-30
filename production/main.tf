module "processing" {
    region = "us-west-2"
    num_machines = 0
    opencap_ecr_repository = aws_ecr_repository.opencap-opencap.repository_url
    openpose_ecr_repository = aws_ecr_repository.opencap-openpose.repository_url
    opencap_api_ecr_repository = aws_ecr_repository.opencap-api.repository_url
    mmpose_ecr_repository = aws_ecr_repository.opencap-mmpose.repository_url
    opencap_analysis_max_centerofmass_vpos_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap-analysis/max_centerofmass_vpos"
    opencap_gait_analysis_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap-analysis/gait_analysis"
    opencap_treadmill_gait_analysis_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap-analysis/treadmill_gait_analysis"
    opencap_squat_analysis_ecr_repository = "660440363484.dkr.ecr.us-west-2.amazonaws.com/opencap-analysis/squat_analysis"
    source = "../modules/processing"

    # For auto-scaling, keep max size to 0 for not using it.
    processing_asg_scaling_config = {
        min_size = 0
        max_size = 0
        desired_size = 0
    }

    processing_asg_scaling_target  = 5
    processing_asg_trials_baseline = 3

    # processing_asg_instance_type = "g5.2xlarge"
    # processing_ecs_task_memory = 30146
    processing_asg_instance_type = "g5.xlarge"
    processing_ecs_task_memory = 15073
}
