# Root Terraform configuration for the Intelligent CI/CD Pipeline Troubleshooting Assistant project.
# This file orchestrates the deployment of network and EKS cluster resources
# by calling local modules defined in the `modules/` directory.

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  # This data source is used to get a list of available AZs in the selected region.
  # It's good practice to use this to make the configuration more resilient to AZ changes.
  # Filter for zones that are currently available and not in an impaired state.
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"] # For regions where all AZs are enabled by default
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

module "network" {
  source = "./modules/network" # Path to the local network module

  vpc_name           = "${var.project_name}-vpc"
  cluster_name_tag   = var.cluster_name # For tagging subnets correctly for EKS
  vpc_cidr           = var.vpc_cidr
  azs                = slice(data.aws_availability_zones.available.names, 0, var.num_azs) # Use a configurable number of AZs
  public_subnet_cidrs= var.public_subnet_cidrs
  private_subnet_cidrs= var.private_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = true # Keep true for demo/cost, can be parameterized
  enable_dns_hostnames = true

  common_tags = var.common_tags
}

module "eks_cluster" {
  source = "./modules/eks_cluster" # Path to the local EKS module

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids # Deploy EKS nodes into private subnets

  eks_managed_node_groups = {
    default_group = { # Example node group
      instance_types = var.node_instance_types
      min_size       = var.node_min_capacity
      max_size       = var.node_max_capacity
      desired_size   = var.node_desired_capacity
      disk_size      = 20 # GB
      ami_type       = "AL2_x86_64" # Amazon Linux 2
      labels         = { "nodegroup-type" = "default" }
      tags           = { "NodeGroup" = "Default" }
    }
    # Add more node groups here if needed
  }

  manage_aws_auth_configmap = true
  aws_auth_roles            = var.aws_auth_roles # Pass roles for aws-auth configmap
  # aws_auth_users         = [] # Define if needed
  # aws_auth_accounts      = [] # Define if needed

  common_tags = var.common_tags
}
