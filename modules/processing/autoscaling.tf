resource "aws_key_pair" "debug" {
  key_name   = "debug-key${var.env}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmd7Qha4ap/ANTyLOf646BobdMDrG0Bbfqt2RxhEMVbXajHpLg4t1uxf58shZQSJwG+yNuxruZPYQj821zCNGeY/z2mJsTst2qMqJEyI4eQDPypyT8iKBPGkOSn6NUxTLmNVH/g9msc2LP2B4Kui8F0Rts5HwaM3i1EhVkU0b+Fx6Z84r799XAYHQpu31W8ZKkj3B0Rrk/7iE1GjEf4LYIz6WkZPFMxEfscZm7pqa/BYJb7wCtryCjktmHBhebnQFF7Xv4GTPBuMfj6A1SHJBz8N0QMNnkdhzc4ucOq8V5UecIIEkOfxcl+S43g4rgabBlfmD8CQYFMG+VUdFuX3UKHkL0l/0JEzToTRmJFQuYw3LsKe1VXCrSc3wY+qk5KRMPGgx/VAxSFkojpGmbGugmSxwKz6eZ4PFBCazVehaNeapnDDIxXOfeDoqIWYvIpPZ7lEje0cPSjOL4wCJeYPv/JZdXEeCJDgIOC4663/uKw3dv2fFK/Cl5S26DE+Ng1SE= kidzik@kidzik-Precision-3640-Tower"
}

data "aws_ami" "latest_ecs" {
  most_recent = true
  owners = ["591542846629"] # AWS

  # filter {
  #     name   = "name"
  #     values = ["*amazon-ecs-optimized"]
  # }

  filter {
      name   = "name"
      values = ["amzn2-ami-ecs-gpu-hvm*x86_64-ebs"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }  
}

### Launch Template ###
locals {
    lt_user_data_raw = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config
    EOF
}

resource "aws_launch_template" "ecs_worker_launch_template" {
    count = !var.processing_asg_use_launch_config ? 1 : 0

    name_prefix               = "${var.app_name}-processing-worker${var.env}"
    image_id                  = data.aws_ami.latest_ecs.image_id
    iam_instance_profile {
        name = aws_iam_instance_profile.ecs_agent.name
    }
    # vpc_security_group_ids    = [aws_security_group.ecs_sg.id]
    user_data                 = base64encode(local.lt_user_data_raw)
    instance_type             = var.processing_asg_instance_type
    key_name                  = aws_key_pair.debug.key_name

    block_device_mappings {
        device_name = "/dev/xvda"

        ebs {
            volume_size = 128
        }
    }

    network_interfaces {
        associate_public_ip_address = true
        security_groups             = [aws_security_group.ecs_sg.id]
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "worker_lt_asg" {
    count = !var.processing_asg_use_launch_config ? 1 : 0

    name                      = "${var.app_name}-processing-worker-asg${var.env}"
    vpc_zone_identifier       = [values(aws_subnet.pub_subnet)[0].id]
    launch_template {
        id      = aws_launch_template.ecs_worker_launch_template[0].id
        version = "$Latest"
    }

    desired_capacity          = var.processing_asg_scaling_config.desired_size
    min_size                  = var.processing_asg_scaling_config.min_size
    max_size                  = var.processing_asg_scaling_config.max_size

    # We need to scale-in only the instances that are not doing any work
    # See https://github.com/stanfordnmbl/opencap-core/issues/113 for the *when* it happens
    protect_from_scale_in     = true

    health_check_grace_period = 300
    health_check_type         = "EC2"
}

## Link ASG to ECS
resource "aws_ecs_capacity_provider" "worker_lt_gpu_provider" {
    name = "${var.app_name}-processing-worker-gpu-capacity${var.env}"

    auto_scaling_group_provider {
        auto_scaling_group_arn         = var.processing_asg_use_launch_config ? aws_autoscaling_group.opencap_processing_asg[0].arn : aws_autoscaling_group.worker_lt_asg[0].arn
        managed_termination_protection = "DISABLED"

        managed_scaling {
            status         = "ENABLED"
            target_capacity = 100
            minimum_scaling_step_size = 1
            maximum_scaling_step_size = 2
        }
    }
}

## Scaling on CloudWatch metric
# Auto Scaling based on CloudWatch metric
resource "aws_appautoscaling_target" "ecs_target" {
    # We're scaling ECS service and AS group 1:1 as we dedicate 1 instance per worker
    max_capacity       = var.processing_asg_scaling_config.max_size
    min_capacity       = var.processing_asg_scaling_config.min_size

    resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.worker.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "target_tracking" {
  name               = "${var.app_name}-processing-worker-target-tracking${var.env}"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = var.processing_asg_scaling_target
    scale_in_cooldown  = 30
    scale_out_cooldown = 30

    customized_metric_specification {
      metric_name = "opencap_trials_pending"
      namespace   = "Custom/opencap${var.env}"
      statistic   = "Average"
    }
  }
}

### Launch Configuration | Deprecated ###
resource "aws_launch_configuration" "ecs_launch_config" {
    count = var.processing_asg_use_launch_config ? 1 : 0

    name                 = "${var.app_name}-processing-workers${var.env}"
    image_id             = data.aws_ami.latest_ecs.image_id
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.ecs_sg.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=${var.app_name}-processing-cluster >> /etc/ecs/ecs.config"
    instance_type        = var.processing_asg_instance_type
    key_name             = aws_key_pair.debug.key_name
    associate_public_ip_address = true

    root_block_device {
        volume_size = 128
    }
}

resource "aws_autoscaling_group" "opencap_processing_asg" {
    count = var.processing_asg_use_launch_config ? 1 : 0

    name                      = "asg${var.env}"
    vpc_zone_identifier       = [values(aws_subnet.pub_subnet)[0].id]
    launch_configuration      = aws_launch_configuration.ecs_launch_config[0].name

    desired_capacity          = var.num_machines
    min_size                  = 0
    max_size                  = var.num_machines
    health_check_grace_period = 300
    health_check_type         = "EC2"
}
