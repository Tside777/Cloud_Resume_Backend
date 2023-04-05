terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
      }
    }
}

provider "aws" {
    region = "us-east-1"
}

module "dynamodb" {
    source = "./modules/aws-dynamodb"
}

module "lambda" {
    source = "./modules/aws-lambda/"
    db_arn = module.dynamodb.db_arn
}