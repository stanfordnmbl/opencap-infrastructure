resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id
    
}

resource "aws_route_table_association" "route_table_association" {
    subnet_id      = aws_subnet.pub_subnet.id
    route_table_id = aws_route_table.public.id
}