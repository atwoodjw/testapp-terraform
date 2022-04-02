provider "aws" {
  region  = "us-east-1"
  profile = "skunkworks"

  default_tags {
    tags = {
      Environment = local.environment,
      Terraform   = "true"
    }
  }
}

locals {
  environment      = terraform.workspace == "default" ? "dev" : terraform.workspace
  name_environment = "${var.name}-${local.environment}"
}

module "network" {
  source           = "./network"
  name_environment = local.name_environment
}

module "application" {
  source              = "./application"
  name_environment    = local.name_environment
  vpc_id              = module.network.vpc_id
  vpc_private_subnets = module.network.vpc_private_subnets
  vpc_public_subnets  = module.network.vpc_public_subnets
}

module "pipeline" {
  source           = "./pipeline"
  environment      = local.environment
  name_environment = local.name_environment
}
