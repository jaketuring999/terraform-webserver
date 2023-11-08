# Initialize terraform for aws
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0" #TODO pick version of aws provider
    }
  }
}

provider "aws" {
  region = "us-east-1" #TODO pick region for aws
  profile = "terraform"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" #TODO pick cidr block for vpc
  enable_dns_support = true

  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet 1 for for VPC
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a" #TODO pick availability zone
  map_public_ip_on_launch = true
  tags = {
  Name = "public_subnet_1"
  }
}

# Public Subnet 2 for for VPC
resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b" #TODO pick availability zone
  map_public_ip_on_launch = true
  tags = {
  Name = "public_subnet_2"
  }
}

# Create an internet gateway for the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main_gateway"
  }
}

# Create EIP for nat gateway 1
resource "aws_eip" "nat_1" {
  domain = "vpc"
  tags = {
    Name = "EIP for NAT Gateway 1"
  }
}

# Create nat gateway_1 for the public subnet 1
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id = aws_subnet.public_subnet_1.id
  tags = {
    Name = "nat_gateway_1"
  }
}

# Create EIP for nat gateway 2
resource "aws_eip" "nat_2" {
  domain = "vpc"
  tags = {
    Name = "EIP for NAT Gateway 2"
  }
}

# Create nat gateway_2 for the public subnet 2
resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id = aws_subnet.public_subnet_2.id
  tags = {
    Name = "nat_gateway_2"
  }
}

# Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public_route_table"
  }
}

# Create route table for subnet 1
resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create route table for subnet 2
resource "aws_route_table_association" "public_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create private subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a" #TODO pick availability zone

  tags = {
    Name = "private_subnet_1"
  }
}

# Create private subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b" #TODO pick availability zone

    tags = {
        Name = "private_subnet_2"
    }
}

# Create ELB
resource "aws_elb" "web_elb" {
  name = "web_elb"
  availability_zones = ["us-east-1a", "us-east-1b"] #TODO pick availability zones

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check { #TODO pick health check
    healthy_threshold   = 2
    interval            = 30
    target              = "HTTP:80/"
    timeout             = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web_elb"
  }
}

# Define launch configuration
resource "aws_launch_configuration" "web_config" {
  name_prefix   = "web_config"
  image_id      = "" #TODO pick image id
  instance_type = "t2.micro" #TODO pick instance type
  security_groups = [aws_security_group.web_sg.id] #TODO pick security group
  lifecycle {
    create_before_destroy = true
  }
}
# Create autoscaling group
resource "aws_autoscaling_group" "web_asg" {
  launch_configuration = aws_launch_configuration.web_config.id
  vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  max_size = 2
  min_size = 5
  health_check_type = "ELB"
  health_check_grace_period = 300
  desired_capacity = 2
  force_delete = true

  tag {
    key = "Name"
    value = "web_asg"
    propagate_at_launch = true
  }
}




# Create s3 bucket outside of the VPC
resource "aws_s3_bucket" "webserver_s3" {
  bucket = "webserver_s3"
  tags = {
    Name = "webserver_s3"
  }
}

# Create an availability zone 1 and 2
