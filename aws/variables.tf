
variable "instance_type" {
  description = "AWS Instance Type to create resources in."
  type = string
  default = "t2.micro"
}

variable "db_instance_type" {
  description = "AWS Instance Type to create resources in."
  type = string
  default = "db.t2.micro"

}

variable "elasti_cache_instance_type" {
  description = "AWS Instance Type to create resources in."
  type = string
  default = "cache.t2.micro"
}
variable "ami" {
  description = "AWS AMI to create resources in."
  type = string
  default = "ami-0fc5d935ebf8bc3bc"
}

variable "region" {
  description = "AWS Region to create resources in."
  type = string
  default = "us-east-1"
}


variable "db_name" {
  type = string
  default = "webserverdb"
}
variable "domain" {
  type = string
  default = "example.com"
}
variable "db_pass" {
  type = string
  sensitive = true
}
variable "sub_domain" {
  type = string
  default = "www"

}

variable "min_elb_capacity" {
  type = number
  default = 2
}

variable "max_elb_capacity" {
  type = number
  default = 5
}
variable "desired_elb_capacity" {
  type = number
  default = 3
}

variable "bucket_name" {
  type = string
  default = "my-elb-logs-bucket"
}

# Create variable for availability zones
variable "availability_zones" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "database_storage" {
  type = number
  default = 20
}

variable "backup_retention_period" {
  type = number
  default = 7
}

variable "database_user" {
  type = string
  default = "webapp_db"
}

variable "num_cache_nodes" {
  type = number
  default = 1
}

variable "waf_rate_limit" {
  type = number
  default = 1000
}

variable "ssh_ip_address" {
  type = list(string)
    default = ["0.0.0.0/0"]
}

variable "key_pair_name" {
  type = string
  default = "my-key-pair"
}