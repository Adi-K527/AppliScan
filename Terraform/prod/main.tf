terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~>4.0"
    }
  }
  backend "s3" {
    bucket  = "appliscan-state-bucket-1615"
    key     = "global/s3/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_access_key
}

provider "google" {
  project     = "appliscan-413019"
  region      = "us-central1"
}

module "cloudfront_distribution" {
  source         = "./modules/cloudfront"
  s3_bucket_name = "appliscan-frontend"
  cloudfront_id  = "E1Y7X66I2J9J8Y"
}

module "ecr_repository" {
  source   = "./modules/elastic-container-registry"
  ecr_name = "appli-scan"
}

module "model_function_job_status" {
  source         = "./modules/lambda"
  repository_url = module.ecr_repository.ecr_url
  function_name  = "JobStatusModel"
}

module "model_function_ner" {
  source         = "./modules/lambda"
  repository_url = module.ecr_repository.ecr_url
  function_name  = "NerModel"
}

module "api_gateway_endpoint_job_status" {
  source            = "./modules/api-gateway"
  path              = "JobStatusModel"
  lambda_invoke_arn = module.model_function_job_status.invoke_arn
}

module "api_gateway_endpoint_ner" {
  source            = "./modules/api-gateway"
  path              = "NerModel"
  lambda_invoke_arn = module.model_function_ner.invoke_arn
}

module "gcp_registry" {
  source = "./modules/artifact-registry"
  registry_name = "appliscan-gcp-registry"
}

module "cloud_run_backend" {
  source   = "./modules/cloud-run"
  gcr_name = "appliscan-cloudrun-backend-8264"
}