# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.13.0

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.13.0"

  name = "${var.name_environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true # TODO: Remove

  # enable_vpn_gateway = true
}

# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.13.0/submodules/vpc-endpoints

module "vpc-endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 3.13.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  # endpoints = {
  #   s3 = {
  #     service = "s3"
  #     tags = { Name = "s3-vpc-endpoint" }
  #   },
  # }
}