
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.56"
    }
  }
}

provider "aws" {
   region = "eu-west-2"

}

# resource "aws_vpc" "siva" {
#   cidr_block       = var.vpc_cidr
#   instance_tenancy = "default"
#   tags = {
#     Name = "siva-vpc" # configure our own name 
#   }
# }


resource "aws_subnet" "public-subnet1" {
  vpc_id                  = var.main_vpc
  cidr_block              = var.subnet1_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-2a"
  tags = {
    Name = "public-subnet1"
  }
}
#public-subnet2 creation
resource "aws_subnet" "public-subnet2" {
  vpc_id                  = var.main_vpc
  cidr_block              = var.subnet2_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-2b"
  tags = {
    Name = "public-subnet2"
  }
}
#private-subnet1 creation
resource "aws_subnet" "private-subnet1" {
  vpc_id                  = var.main_vpc
  cidr_block        = var.subnet3_cidr
  availability_zone = "eu-west-2a"
  tags = {
    Name = "private-subnet1"
  }
}

resource "aws_internet_gateway" "siva-gateway" {
  vpc_id                  = var.main_vpc
}

resource "aws_route_table" "route" {
  vpc_id                  = var.main_vpc

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.siva-gateway.id
  }
  tags = {
    Name = "route to internet"
  }
}
#route 1
resource "aws_route_table_association" "route1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.route.id
}
#route 2
resource "aws_route_table_association" "route2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.route.id
}

resource "aws_security_group" "web-sg" {
     vpc_id                  = var.main_vpc
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-sg"
  }
}

resource "aws_lb" "external-alb" {
  name               = "External-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-sg.id]
  subnets            = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]
}
resource "aws_lb_target_group" "target_elb" {
  name     = "ALB-TG"
  port     = 80
  protocol = "HTTP"
   vpc_id                  = var.main_vpc
  health_check {
    path     = "/health"
    port     = 80
    protocol = "HTTP"
  }
}
resource "aws_lb_target_group_attachment" "ecomm" {
  target_group_arn = aws_lb_target_group.target_elb.arn
  target_id        = var.qwatt_beta_server
  port             = 80
  depends_on = [
    aws_lb_target_group.target_elb,   
  ]
}

resource "aws_lb_listener" "listener_elb" {
  load_balancer_arn = aws_lb.external-alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_elb.arn
  }
}