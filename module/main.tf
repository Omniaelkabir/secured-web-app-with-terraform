# Create vpc

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name= "MyVpc"
  }
}

# Create subnets two public and two private

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
  cidr_block = var.subnets_cidr[2]
  availability_zone = var.az1
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-Subnet1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_cidr[3]
  availability_zone = var.az2
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

# Create security groups
resource "aws_security_group" "secgroup" {
  description = "Allow HTTP traffic from anywhere"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "secgroup"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_from_anywhere]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_from_anywhere]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_from_anywhere]
  }
}
# Create Public Loadbalancer
resource "aws_lb" "public-lb" {
  name               = "pub-lb"
  internal           = false
  load_balancer_type = "application"
   ip_address_type = "ipv4"
  security_groups    = [aws_security_group.secgroup.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
  tags = {
    Name = "My-public-lb"
  }
}
resource "aws_lb_target_group" "publicgroup" {
  name     = "pub-targetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name = "My-public-targetgroup"
  }
}
resource "aws_lb_target_group_attachment" "attach-proxy1" {
  target_group_arn = aws_lb_target_group.publicgroup.arn
  target_id        = var.publicvmid1
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-proxy2" {
  target_group_arn = aws_lb_target_group.publicgroup.arn
  target_id        = var.publicvmid2
  port             = 80
}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.public-lb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.publicgroup.arn
  }
}
# Create Private Loadbalancer
resource "aws_lb" "private-lb" {
  name               = "priv-lb"
  internal           = true
  ip_address_type = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.secgroup.id]
  subnets            = [aws_subnet.private1.id, aws_subnet.private2.id]
  tags = {
    Name = "My-private-lb"
  }
}
resource "aws_lb_target_group" "privategroup" {
  name     = "priv-targetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name = "My-private-targetgroup"
  }
}
resource "aws_lb_target_group_attachment" "attach-priv1" {
  target_group_arn = aws_lb_target_group.privategroup.arn
  target_id        = var.privatevmid1
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-priv2" {
  target_group_arn = aws_lb_target_group.privategroup.arn
  target_id        = var.privatevmid2
  port             = 80
}
resource "aws_lb_listener" "listener1" {
  load_balancer_arn = aws_lb.private-lb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.privategroup.arn
  }
}