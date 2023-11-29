# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true

  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet 1 for for VPC
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
  Name = "public_subnet_1"
  }
}

# Public Subnet 2 for for VPC
resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
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
