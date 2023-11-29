
# RDS database subnet group across two Availability Zones
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags = {
    Name = "db-subnet-group"
  }
}

# RDS instance (relational database)
resource "aws_db_instance" "rds_db_instance" {
  allocated_storage    = var.database_storage
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_type
  backup_retention_period = var.backup_retention_period
  username             = var.database_user
  password             = var.db_pass
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = false
  multi_az             = true

  tags = {
    Name = "mydb"
  }
}

# Security group for RDS
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Security group for RDS DB Instance"
  vpc_id      = aws_vpc.main.id

  # Ingress rule allowing MySQL traffic from the application servers' security group only
  ingress {
    from_port   = 3306 #Allows MySQL traffic only
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "db-sg"
  }
}