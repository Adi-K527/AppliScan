terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~>4.0"
    }
  }

  backend "s3" {
    bucket  = "appliscan-state-bucket"
    key     = "global/s3/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = local.envs["AWS_ACCESS_KEY_ID"]
  secret_key = local.envs["AWS_SECRET_ACCESS_KEY"]
}

resource "aws_ecr_repository" "appliscan_ecr" {
  name = local.envs["APPLISCAN_ECR"]

  provisioner "local-exec" {
    command = <<-EOT
      docker pull alpine
      docker tag alpine appli-scan:latest ${aws_ecr_repository.repository.repository_url}:latest
      docker push ${aws_ecr_repository.repository.repository_url}:latest
    EOT
  }
}