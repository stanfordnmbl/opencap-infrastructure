data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  az_names = data.aws_availability_zones.azs.names
}

resource "aws_subnet" "pub_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = cidrsubnet(var.cidr[var.env], 4, each.key)

    for_each                = {for idx, az_name in local.az_names: idx => az_name}
    availability_zone       = local.az_names[each.key]
    map_public_ip_on_launch = true
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "main${var.env}"
  subnet_ids = [aws_subnet.pub_subnet.0.id, aws_subnet.pub_subnet.1.id, aws_subnet.pub_subnet.2.id, aws_subnet.pub_subnet.3.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "redis${var.env}"
  subnet_ids = [aws_subnet.pub_subnet.0.id, aws_subnet.pub_subnet.1.id, aws_subnet.pub_subnet.2.id, aws_subnet.pub_subnet.3.id]

  tags = {
    Name = "My Redis subnet group"
  }
}
