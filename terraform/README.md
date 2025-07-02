# Terraform Configuration for Intelligent CI/CD Troubleshooting Assistant

This directory contains the Terraform configuration for provisioning the AWS infrastructure required by the Intelligent CI/CD Troubleshooting Assistant project. This primarily includes a Virtual Private Cloud (VPC) and an Elastic Kubernetes Service (EKS) cluster.

**Note:** The associated GitHub Actions workflow is configured to run `terraform plan` for pull requests and pushes, but it **does not automatically apply** these configurations to deploy actual resources. Manual intervention or further configuration would be needed for actual deployment.

## Structure

The Terraform configuration is organized into a root module and local modules for better separation of concerns:

-   **Root Module (`terraform/`)**:
    -   `main.tf`: Orchestrates the deployment by calling local modules. Defines AWS provider and data sources.
    -   `variables.tf`: Contains input variables for customizing the deployment (e.g., region, VPC CIDRs, EKS version).
    -   `outputs.tf`: Exposes key outputs from the deployed infrastructure (e.g., VPC ID, EKS cluster endpoint).
    -   `versions.tf`: Specifies required versions for Terraform and AWS provider.
-   **Local Modules (`terraform/modules/`)**:
    -   **`network/`**:
        -   Manages the creation of the VPC, subnets (public and private), NAT Gateways, and related networking resources.
        -   It wraps the public `terraform-aws-modules/vpc/aws` module.
        -   Contains its own `main.tf`, `variables.tf`, and `outputs.tf`.
    -   **`eks_cluster/`**:
        -   Manages the creation of the EKS cluster, including managed node groups.
        -   It wraps the public `terraform-aws-modules/eks/aws` module.
        -   Contains its own `main.tf`, `variables.tf`, and `outputs.tf`.

## Prerequisites

-   **Terraform CLI**: Version specified in `versions.tf` (e.g., `>= 1.3.0`).
-   **AWS Credentials**: To run `terraform plan` or `apply`, you need AWS credentials configured in your environment that have permissions to create the necessary resources (VPC, EKS, IAM roles, etc.). This typically involves setting `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_DEFAULT_REGION` environment variables. The GitHub Actions workflow expects these as secrets if it were to perform a full plan against an AWS account or apply changes.

## Usage

1.  **Initialization**:
    Navigate to the `terraform/` directory and run:
    ```bash
    terraform init
    ```
    This will download the necessary providers and modules.

2.  **Planning**:
    To see what infrastructure changes Terraform will make, run:
    ```bash
    terraform plan
    ```
    You can use a `.tfvars` file to override default variable values:
    ```bash
    terraform plan -var-file="my_vars.tfvars"
    ```

3.  **Applying (Manual - Not part of automated CI)**:
    **Warning**: This will create resources in your AWS account and may incur costs.
    If you intend to deploy the infrastructure manually:
    ```bash
    terraform apply
    ```
    Or with a plan file:
    ```bash
    terraform plan -out=tfplan
    terraform apply tfplan
    ```

4.  **Destroying (Manual)**:
    **Warning**: This will destroy all resources managed by this Terraform configuration.
    ```bash
    terraform destroy
    ```

## Inputs (Root `variables.tf`)

Key variables you might want to customize:

-   `aws_region`: The AWS region for deployment.
-   `project_name`: Used for naming and tagging.
-   `vpc_cidr`: CIDR block for the VPC.
-   `num_azs`: Number of Availability Zones to use (affects subnet creation).
-   `public_subnet_cidrs` / `private_subnet_cidrs`: CIDR blocks for subnets (ensure list length matches `num_azs`).
-   `cluster_name`: Name for the EKS cluster.
-   `eks_version`: Kubernetes version for EKS.
-   `node_instance_types`: EC2 instance types for EKS worker nodes.
-   `node_desired_capacity`, `node_min_capacity`, `node_max_capacity`: Sizing for the default EKS node group.
-   `aws_auth_roles`: IAM roles to grant admin access to the EKS cluster.

Refer to `terraform/variables.tf` for all available variables and their default values.

## Outputs (Root `outputs.tf`)

Key outputs after a successful apply:

-   `vpc_id`: ID of the created VPC.
-   `eks_cluster_name`: Name of the EKS cluster.
-   `eks_cluster_endpoint`: Endpoint for the EKS Kubernetes API.
-   `eks_cluster_oidc_issuer_url`: OIDC issuer URL for IAM Roles for Service Accounts (IRSA).

Refer to `terraform/outputs.tf` for all available outputs.
