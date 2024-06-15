locals {
  envs = {
    for tuple in regexall("(.*)=(.*)", file("../../.env")) : tuple[0] => chomp(tuple[1]) 
  }
}

variable "access_key" {
  description  = "AWS access key"
  type         = string
}

variable "secret_access_key" {
  description  = "AWS secret access key"
  type         = string
}

variable "ecr_name" {
  description  = "ECR name"
  type         = string
}