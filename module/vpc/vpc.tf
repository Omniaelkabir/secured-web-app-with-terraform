
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name= "vpc1"
  }
}


variable "vpc_cidr" {
  type = string
}