terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8"
    }
  }
}

provider "aws" {}

data "aws_region" "current" {}

module "api" {
  source            = "../."
  endpoint_suffix   = "${data.aws_region.current.name}.amazonaws.com"
}

output "endpoint" {
  value = module.api.rest_api_endpoint
}
