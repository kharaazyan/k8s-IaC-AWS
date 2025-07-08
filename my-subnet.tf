resource "aws_subnet" "pub-sub" {
  vpc_id                  = aws_vpc.k8s-vpc.id
  cidr_block              = var.pub_subnet_cidr
  map_public_ip_on_launch = var.public_ip
  tags = {
    Name = "pub-sub"
  }
  depends_on = [aws_vpc.k8s-vpc]
}
