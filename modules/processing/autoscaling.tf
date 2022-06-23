resource "aws_key_pair" "debug" {
  key_name   = "debug-key"
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
      values = ["amzn2-ami-ecs-hvm*x86_64-ebs"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }  
}

resource "aws_launch_configuration" "ecs_launch_config" {
    image_id             = data.aws_ami.latest_ecs.image_id
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.ecs_sg.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=opencap_processing >> /etc/ecs/ecs.config"
    instance_type        = "m5.large"
    key_name             = aws_key_pair.debug.key_name
    associate_public_ip_address = true
}


resource "aws_autoscaling_group" "opencap_processing_asg" {
    name                      = "asg"
    vpc_zone_identifier       = [values(aws_subnet.pub_subnet)[0].id]
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name

    desired_capacity          = var.num_machines
    min_size                  = 1
    max_size                  = var.num_machines
    health_check_grace_period = 300
    health_check_type         = "EC2"
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "opencap-db-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
  publicly_accessible = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
}


resource "aws_rds_cluster" "default" {
  cluster_identifier = "opencap-db-cluster"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  database_name      = "opencap"
  master_username    = local.db_creds.username
  master_password    = local.db_creds.password
  engine             = "aurora-postgresql"
  storage_encrypted  = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
}