
provider "aws" {
  region = "us-east-1"
  profile = "mis" #MUST MATCH PROFILE NAME IN AWS credentials file
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

variable "db_pass" {
  type = string
  sensitive = true
}

module "aws_module" {
  source = "../aws"
  region = "us-east-1" # Replace with your region
  instance_type = "t2.micro" # Replace with your instance type
  db_instance_type = "db.t2.micro" # Replace with your instance type
  elasti_cache_instance_type = "cache.t2.micro" # Replace with your instance type
  ami = "ami-0fc5d935ebf8bc3bc" # Replace with your ami
  domain = "example.com" # Replace with your domain
  sub_domain = "www"  # Replace with your sub domain
  min_elb_capacity = 2 # Replace with your min capacity
  max_elb_capacity = 5 # Replace with your max capacity
  desired_elb_capacity = 3 # Replace with your desired capacity
  database_storage = 20 # Replace with your database storage
  backup_retention_period = 7 # Replace with your backup retention period
  num_cache_nodes = 1 # Replace with your number of cache nodes
  availability_zones = ["us-east-1a", "us-east-1b"] # Replace with your availability zones
  bucket_name = "my-elb-logs-bucket" # Replace with your bucket name **MUST BE globally UNIQUE**
  db_name = "default_username" # Replace with your database name
  db_pass = var.db_pass # Replace with your database password
  key_pair_name = "my-key-pair" # Replace with your key pair name
  waf_rate_limit = 1000 # Replace with your rate limit
  ssh_ip_address = ["0.0.0.0/0"] # Add your ip address here
}