resource "aws_subnet" "private" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet"
  }
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}