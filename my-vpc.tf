resource "aws_vpc" "k8s-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "k8s-vpc"
  }
}