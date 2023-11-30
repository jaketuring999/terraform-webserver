# Elasticache Redis cluster
resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id           = "cache-cluster"
  engine               = "redis"
  node_type            = var.elasti_cache_instance_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = "default.redis3.2"
  engine_version       = "7.1"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.elasticache_subnet_group.name
}

# Elasticache subnet group for a dedicated subnet
resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "cache-subnet-group"
  subnet_ids = [aws_subnet.elasticache_subnet.id]  # Subnet dedicated to Elasticache

  tags = {
    Name = "cache-subnet-group"
  }
}

# Subnet dedicated to Elasticache
resource "aws_subnet" "elasticache_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "elasticache-subnet"
  }
}

# Security group for the Elasticache cluster
resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache-sg"
  description = "Security group for Elasticache"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6379  # Default Redis port
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "elasticache-sg"
  }
}
