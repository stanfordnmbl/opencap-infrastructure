resource "aws_security_group" "ecs_sg" {
    vpc_id      = aws_vpc.vpc.id

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}
