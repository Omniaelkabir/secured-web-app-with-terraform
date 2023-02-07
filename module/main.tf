# provider "aws" {
#   region = var.region
# }



# variable "region" {
#   type = string
# }
# create vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name= "MyVpc"
  }
}

# create subnets two public and two private
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_cidr[0]
  availability_zone = var.az1
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_cidr[1]
  availability_zone = var.az2
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr[2]
  availability_zone = var.az1
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-Subnet1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr[3]
  availability_zone = var.az1
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-Subnet2"
  }
}

# Create public route table

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public-Route"
  }
}

# Create internet getaway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "My-igw"
  }
}

resource "aws_route" "igw-route" {
  route_table_id            = aws_route_table.public-route.id
  destination_cidr_block    = var.cidr_from_anywhere
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "first-public" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-route.id
}
resource "aws_route_table_association" "second-public" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-route.id
}

#  Create private route table
resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Private-Route"
  }
  
}

# Create nat gateway and elastic ip
resource "aws_eip" "eip" {
    vpc = true
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "My-natway"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "natgw-route" {
  route_table_id            = aws_route_table.private-route.id
  destination_cidr_block    = var.cidr_from_anywhere
  gateway_id = aws_nat_gateway.nat-gw.id
}
resource "aws_route_table_association" "first-private" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private-route.id
}
resource "aws_route_table_association" "second-private" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private-route.id
}
