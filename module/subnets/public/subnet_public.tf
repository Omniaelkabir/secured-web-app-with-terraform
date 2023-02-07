resource "aws_subnet" "public" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet"
  }
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}