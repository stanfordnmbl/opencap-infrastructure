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
    # ECS cluster settings
    echo 'ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name}' >> /etc/ecs/ecs.config
    echo 'ECS_ENABLE_CONTAINER_METADATA=true' >> /etc/ecs/ecs.config
    echo 'ECS_RESERVED_MEMORY=256' >> /etc/ecs/ecs.config
    # Install jq
    apt update && apt install -y jq
    # Modify Docker config to allow GPU sharing
    # Backup existing daemon.json
    if [ ! -f /etc/docker/daemon.json ]; then
        echo '{}' > /etc/docker/daemon.json
    fi
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.orig
    # Update the daemon.json file
    sudo jq '. + {"default-ulimit": {"nofile": ["32768:65536"]}, "default-runtime": "nvidia"}' /etc/docker/daemon.json.orig | sudo tee /etc/docker/daemon.json
    # Restart Docker to apply changes
    sudo systemctl restart docker
    EOF
}

resource "aws_launch_template" "ecs_worker_launch_template" {
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
    name                      = "${var.app_name}-processing-worker-asg${var.env}"
    vpc_zone_identifier       = [values(aws_subnet.pub_subnet)[0].id]
    launch_template {
        id      = aws_launch_template.ecs_worker_launch_template.id
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

    tag {
        key                 = "AmazonECSManaged"
        value               = true
        propagate_at_launch = true
    }

    lifecycle {
      ignore_changes = [
        desired_capacity,
      ]
    }
}

## Link ASG to ECS
resource "aws_ecs_capacity_provider" "worker_lt_gpu_provider" {
    name = "${var.app_name}-processing-worker-gpu-capacity${var.env}"

    auto_scaling_group_provider {
        auto_scaling_group_arn         = aws_autoscaling_group.worker_lt_asg.arn
        managed_termination_protection = "DISABLED"

        managed_scaling {
            status         = "ENABLED"
            target_capacity = 100
            minimum_scaling_step_size = 1
            maximum_scaling_step_size = 1
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
    disable_scale_in   = false

    customized_metric_specification {
        metrics {
            label = "Get the queue size (the number of messages waiting to be processed)"
            id    = "trials_pending"

            metric_stat {
                metric {
                    metric_name = "opencap_trials_pending"
                    namespace   = "Custom/opencap${var.env}"
                }
                stat = "Average"
            }
            return_data = false
        }

        metrics {
            label = "Get the ECS running task count (the number of currently running tasks)"
            id    = "tasks_running"

            metric_stat {
                metric {
                    metric_name = "RunningTaskCount"
                    namespace   = "ECS/ContainerInsights"

                    dimensions {
                        name  = "ClusterName"
                        value = aws_ecs_cluster.ecs_cluster.name
                    }

                    dimensions {
                        name  = "ServiceName"
                        value = aws_ecs_service.worker.name
                    }
                }
                stat = "Average"
            }

            return_data = false
        }

        metrics {
            label      = "Number of always available instances"
            id         = "trials_baseline"
            expression = var.processing_asg_trials_baseline
            return_data = false
        }

        metrics {
            label       = "Calculate the backlog per instance excluding the baseline instances"
            id          = "e1"
            expression  = "(trials_pending - trials_baseline) / FILL(tasks_running, 1)"
            return_data = true
        }
    }
  }
}
