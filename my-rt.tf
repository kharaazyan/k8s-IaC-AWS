resource "aws_route_table" "pub-rt" {
  vpc_id     = aws_vpc.k8s-vpc.id
  depends_on = [aws_vpc.k8s-vpc]
  route {
    cidr_block = var.all_inet_subnet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pub-rt"
  }
}

resource "aws_route_table_association" "pub-ass" {
  subnet_id      = aws_subnet.pub-sub.id
  route_table_id = aws_route_table.pub-rt.id
  depends_on     = [aws_route_table.pub-rt]

}
