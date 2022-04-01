terraform {
  backend "s3" {
    bucket  = "terraform-570023175774"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "skunkworks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }

  required_version = ">= 1.1.7"
}
