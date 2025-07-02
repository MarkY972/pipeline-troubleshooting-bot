# Terraform variable definitions.
# This file declares variables used across the Terraform configurations (EKS, VPC, etc.).
# Default values are provided, which are suitable for a demo environment.
# These can be overridden if needed, for example, via a .tfvars file or
# environment variables in a CI/CD pipeline (though not strictly necessary for `terraform plan`).

variable "aws_region" {
  description = "AWS region for deploying the EKS cluster and related resources"
  type        = string
  default     = "us-west-2" # Example region
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones for the VPC"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "eks_version" {
  description = "Desired Kubernetes version for EKS Cluster"
  type        = string
  default     = "1.27"
}

variable "instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}
