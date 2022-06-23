resource "aws_vpc" "vpc" {
    cidr_block = var.cidr[var.region]
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags       = {
        Name = "Terraform VPC"
    }
}

# resource "aws_vpc_peering_connection" "global_analytics" {
#   vpc_id        = aws_vpc.vpc.id
#   peer_vpc_id   = "vpc-05f147cdc209bdc09"
#   peer_region   = "us-east-1"
#   tags = {
#     Name = var.region
#   }
# }

# resource "aws_route" "peer" {
#   route_table_id            = aws_route_table.public.id
#   destination_cidr_block    = "172.32.0.0/16"
#   vpc_peering_connection_id = aws_vpc_peering_connection.global_analytics.id
# }

resource "aws_route" "internet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway.id
}
