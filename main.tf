terraform {
  required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~> 4.0"
      }
  } 
}

provider "aws" {
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
  region     = var.region
}