
provider "aws" {
  region = "us-east-1"
  profile = "mis" #MUST MATCH PROFILE NAME IN AWS credentials file
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0" #TODO pick version of aws provider
    }
  }
}


module "aws_module" {
  source = "../aws"
  region = "us-east-1"
  instance_type = "t2.micro"
  db_instance_type = "db.t2.micro"
  elasti_cache_instance_type = "cache.t2.micro"
  ami = "ami-0fc5d935ebf8bc3bc"
  domain = "jdschuler.com"
  sub_domain = "www"
  min_elb_capacity = 2
  max_elb_capacity = 5
  desired_elb_capacity = 3
  database_storage = 20
  backup_retention_period = 7
  num_cache_nodes = 1
  availability_zones = ["us-east-1a", "us-east-1b"]
  bucket_name = "my-elb-logs-bucket"
  db_name = "default_username"
  key_pair_name = "my-key-pair"
  db_pass = "default"
  waf_rate_limit = 1000
  ssh_ip_address = ["0.0.0.0/0"] # Add your ip address here
}