terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
      }
    }
    backend "s3" {
      bucket = "trevors-cloud-resume-backend-bucket"
      key = "terraform-state"
      region = "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
}

module "s3" {
  source = "./modules/aws-s3-backend/"
}

module "dynamodb" {
    source = "./modules/aws-dynamodb"
}

module "lambda" {
    source = "./modules/aws-lambda/"
    db_arn = module.dynamodb.db_arn
}

module "api_gateway" {
  source = "./modules/aws-api-gateway/"
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
  lambda_name = module.lambda.lambda_name
}

module "cors" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = module.api_gateway.api_id
  api_resource_id = module.api_gateway.api_resource_id
  allow_origin    = "https://www.trevorscloudresume.com"
}