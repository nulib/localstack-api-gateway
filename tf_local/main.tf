terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8"
    }
  }
}

provider "aws" {
  access_key                  = "fake"
  secret_key                  = "fake"
  region                      = "us-east-1"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true


  endpoints {
    apigateway     = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
    iam            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
  }
}

data "aws_region" "current" {}

module "api" {
  source            = "../."
  endpoint_suffix   = "localhost.localstack.cloud:4566"
}

output "endpoint" {
  value = module.api.rest_api_endpoint
}
