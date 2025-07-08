resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8s-vpc.id
  tags = {
    Name = "aws-igw"
  }
}