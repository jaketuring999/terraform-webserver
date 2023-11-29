variable "region" {
  description = "AWS Region to create resources in."
  type = string
  default = "us-east-1"
}

variable "db_pass" {
  type = string
  sensitive = true
}