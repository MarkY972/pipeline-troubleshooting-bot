# Terraform configuration for the Virtual Private Cloud (VPC).
# This file defines the network infrastructure (VPC, subnets, NAT gateway, etc.)
# required for the EKS cluster. It uses the terraform-aws-modules/vpc/aws module.
#
# Note: This configuration is intended for demonstrating the CI/CD pipeline structure.
# The pipeline will run `terraform plan` but not `apply`.

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0" # Specify a version for consistency

  name = "${var.cluster_name}-vpc" # Namespacing VPC with cluster name
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, length(var.azs))
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = true # For cost saving in a demo environment
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"         = "1"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "eks-troubleshooting-assistant"
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}
