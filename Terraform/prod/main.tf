terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~>5.0"
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
}

module "cognito_user_pool" {
  source               = "./modules/cognito"
  cognito_name         = "Appliscan"
  cognito_redirect_url = "http://localhost:3000"
}

resource "aws_s3_bucket" "appliscan_model_bucket" {
  bucket = "appliscan-bucket-325"
}

resource "aws_s3_bucket" "firehose_delivery_bucket" {
  bucket = "appliscan-transformed-emails"
}


module "ecr_repository" {
  source   = "./modules/elastic-container-registry"
  ecr_name = "appli-scan"
}

module "model_functions" {
  for_each       = var.models
  source         = "./modules/lambda"
  repository_url = module.ecr_repository.ecr_url
  function_name  = each.value
  bucket_arn     = aws_s3_bucket.firehose_delivery_bucket.arn
  depends_on     = [ module.ecr_repository, aws_s3_bucket.firehose_delivery_bucket ]
}

resource "aws_api_gateway_rest_api" "appliscan_api" {
  name         = "Appliscan"
  description  = "Appliscan api to interact with models."
}

module "api_gateway_endpoints" {
  for_each             = var.models
  source               = "./modules/api-gateway"
  path                 = each.value
  lambda_invoke_arn    = module.model_functions[each.value].lambda_arn
  lambda_function_name = each.value
  api_id               = aws_api_gateway_rest_api.appliscan_api.id
  api_root_resource_id = aws_api_gateway_rest_api.appliscan_api.root_resource_id
  api_execution_arn    = aws_api_gateway_rest_api.appliscan_api.execution_arn 
}

module "kinesis_data_firehose" {
  source             = "./modules/kinesis-firehose"
  firehose_name      = "appliscan-email-preprocessor"
  lambda_source_file = "./code-files/firehose/lambda_function.py"
  bucket_id = aws_s3_bucket.firehose_delivery_bucket.id
  bucket_arn = aws_s3_bucket.firehose_delivery_bucket.arn
  job_related_model_function_arn = module.model_functions["JobRelatedModel"].lambda_arn
  depends_on = [ module.model_functions["JobRelatedModel"], aws_s3_bucket.firehose_delivery_bucket ]
}

module "email_dynamodb_table" {
  source     = "./modules/dynamodb"
  table_name = "Appliscan_Email_Table"
}

module "gcp_backend_registry" {
  source        = "./modules/artifact-registry"
  registry_name = "appliscan-backend"
}

module "gcp_email_registry" {
  source        = "./modules/artifact-registry"
  registry_name = "appliscan-email-api"
}

module "cloud_run_backend" {
  source   = "./modules/cloud-run"
  gcr_name = "appliscan-cloudrun-backend-8264"
}

module "cloud_run_gmail" {
  source   = "./modules/cloud-run"
  gcr_name = "appliscan-cloudrun-gmail-api-1964"
}

resource "google_cloud_scheduler_job" "token_refresher" {
  name             = "token-refresh-job"
  description      = "Job to refresh email tokens"
  schedule         = "*/10 * * * *"
  time_zone        = "America/New_York"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = "${module.cloud_run_gmail.gcr_url}/refresh"
    headers = {
      "Content-Type" = "application/json"
    }
  }
}
