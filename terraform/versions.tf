# Specifies Terraform version and required provider versions for the project.
# This helps ensure compatibility and predictable behavior when running Terraform.

terraform {
  required_version = ">= 1.3.0" # Specify a minimum Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify a compatible version range for the AWS provider
      # Example: using version 5.0.0 of terraform-aws-modules/vpc/aws
      # and 19.15.3 of terraform-aws-modules/eks/aws.
      # These modules may have their own AWS provider version constraints.
      # It's good to align this with the requirements of the modules being used.
      # Check module documentation for their specific provider requirements if issues arise.
    }
  }
}

# Provider configuration (e.g., region) is handled in main.tf or passed via environment variables.
# This file is solely for version constraints.
