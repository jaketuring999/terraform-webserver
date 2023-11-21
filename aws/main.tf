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