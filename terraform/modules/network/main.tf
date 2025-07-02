# Terraform configuration for the Virtual Private Cloud (VPC)
# This local module defines the network infrastructure (VPC, subnets, NAT gateway, etc.)
# required for the EKS cluster. It uses the public terraform-aws-modules/vpc/aws module.

# Provider configuration is inherited from the root module, so not needed here.
# data "aws_availability_zones" "available" {} # This should be in the root or passed as a variable if needed per module. For now, assume AZs are passed in.

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0" # Specify a version for consistency

  name = var.vpc_name # Use a variable for the VPC name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway # For cost saving in a demo environment
  enable_dns_hostnames = var.enable_dns_hostnames

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name_tag}" = "shared" # Use a variable for cluster name tag
    "kubernetes.io/role/elb"                        = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name_tag}" = "shared" # Use a variable for cluster name tag
    "kubernetes.io/role/internal-elb"               = "1"
  }

  tags = merge(var.common_tags, {
    Name = var.vpc_name
  })
}
