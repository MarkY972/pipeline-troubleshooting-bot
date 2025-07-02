# AGENTS.md - Instructions for AI Agent Development

This document provides guidance for AI agents working on the Intelligent CI/CD Pipeline Troubleshooting Assistant project.

## Project Overview

The goal of this project is to create a GitHub Action that uses an AI-powered assistant to analyze failed builds or deployments and provide intelligent suggestions or remediations.

**Current State:**
- The basic GitHub Actions workflow is set up (`.github/workflows/main.yml`).
- A Python script (`scripts/log_parser.py`) exists to simulate log parsing and AI analysis (using a mock AI client).
- Terraform configurations (`terraform/`) for an EKS cluster and VPC are defined.
- The pipeline is configured to run `terraform init`, `validate`, and `plan` but **does not deploy infrastructure**.
- Conceptual placeholders for suggestion delivery (PR comments, Slack) are in comments.

## Key Files

- `.github/workflows/main.yml`: The main GitHub Actions workflow.
- `scripts/log_parser.py`: Python script for log analysis and AI interaction.
- `scripts/requirements.txt`: Python dependencies for scripts.
- `terraform/`: Directory containing Terraform configurations for AWS EKS.
    - `README.md`: Detailed explanation of the Terraform setup, usage, and structure.
    - `versions.tf`: Specifies required Terraform and provider versions.
    - `main.tf` (root): Orchestrates calls to local modules.
    - `variables.tf` (root): Input variables for the entire Terraform configuration.
    - `outputs.tf` (root): Outputs from the entire Terraform configuration.
    - `modules/`: Contains local, reusable modules.
        - `network/`: Local module for VPC and networking resources. Wraps the public `terraform-aws-modules/vpc/aws` module. Contains its own `main.tf`, `variables.tf`, `outputs.tf`.
        - `eks_cluster/`: Local module for EKS cluster resources. Wraps the public `terraform-aws-modules/eks/aws` module. Contains its own `main.tf`, `variables.tf`, `outputs.tf`.

## Development Guidelines

### 1. OpenAI Integration (Future)
- The `scripts/log_parser.py` currently uses `MockOpenAIClient`.
- To enable real OpenAI integration:
    1. Install the `openai` Python library: `pip install openai`.
    2. Replace `MockOpenAIClient` instantiation with `openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))`.
    3. Ensure the `OPENAI_API_KEY` secret is configured in the GitHub repository and made available to the workflow.
    4. Refine the prompts sent to the OpenAI API in `analyze_logs_with_ai` for better accuracy and more specific suggestions. Consider different prompts for different types of errors (Terraform, application, build).

### 2. Terraform Deployment (Future - Optional)
- The pipeline currently only runs `terraform plan` using the configurations in `terraform/`.
- The Terraform code is structured using local modules (`modules/network` and `modules/eks_cluster`) called by the root module. Refer to `terraform/README.md` for details on structure and usage.
- To enable actual deployment:
    1. **CRITICAL: Ensure AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`) are securely configured as GitHub secrets.**
    2. In `.github/workflows/main.yml`, uncomment the `env` sections for AWS credentials in `Terraform Init` and `Terraform Plan` steps.
    3. Add a `Terraform Apply` step after the `Terraform Plan` step in `.github/workflows/main.yml`, ensuring it only runs on specific conditions (e.g., merges to `main` branch, manual approval).
       ```yaml
       # Example Terraform Apply step in GitHub Actions:
       - name: Terraform Apply
         if: github.ref == 'refs/heads/main' && github.event_name == 'push' # Example condition
         run: terraform -chdir=./terraform apply -auto-approve -no-color
         env:
           AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
           AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
           AWS_DEFAULT_REGION: ${{ secrets.AWS_REGION }} # Or reference var.aws_region if set via tfvars
       ```
    4. **Thoroughly test the Terraform apply process in a non-production environment first.**

### 3. Suggestion Delivery (Future)
- Conceptual comments for PR comments and Slack messages are in `scripts/log_parser.py` and `.github/workflows/main.yml`.
- **For PR Comments:**
    - Use an action like `peter-evans/create-or-update-comment`.
    - Ensure the `GITHUB_TOKEN` has `pull-requests: write` permissions.
    - The `log_parser.py` script's output needs to be captured. The GitHub Actions workflow (`.github/workflows/main.yml`) has comments on how to set step outputs (e.g., `echo "suggestion=value" >> $GITHUB_OUTPUT`) which can then be consumed by the PR comment action.
- **For Slack Messages:**
    - Add `slack_sdk` to `scripts/requirements.txt` and ensure it's installed in the workflow.
    - Configure `SLACK_BOT_TOKEN` and `SLACK_CHANNEL_ID` as GitHub secrets.
    - Implement the Slack sending logic in `log_parser.py` or a separate script.

### 4. Log Capturing in Workflow
- The current workflow simulates log capture from a failed step by writing to `simulated_error_log.txt`.
- For real failures:
    - Explore capturing `stdout` and `stderr` from failed script steps directly using GitHub Actions features (e.g., `steps.<step_id>.outputs.stdout`). This can be complex for large outputs.
    - Consider having critical scripts explicitly write their detailed logs to a file upon failure, which can then be picked up by the `log_parser.py` script.

### 5. Testing
 - **Unit Tests for Python script:** Add unit tests for `log_parser.py` functions, especially if enhancing parsing logic or AI interaction. Use `unittest` or `pytest`. Ensure any new dependencies are added to `scripts/requirements.txt`.
- **Workflow Testing:** Test the GitHub Actions workflow by intentionally causing simulated failures or (if deployment is enabled) actual Terraform errors.
- **AI Prompt Testing:** Iteratively test and refine the prompts sent to the (mock or real) AI to improve the quality of suggestions.

### Coding Conventions
- Follow standard Python (PEP 8) and Terraform HCL conventions.
- Keep comments clear and up-to-date.
- Ensure variable names are descriptive.

## Workflow for AI Agent
1. **Understand the Task:** Clarify requirements before making changes.
2. **Update Plan:** If significant changes are needed, update the plan and seek approval.
3. **Implement Incrementally:** Make small, testable changes.
4. **Test Thoroughly:** Run workflow, add unit tests if applicable.
5. **Document:** Update this `AGENTS.md` if new conventions or procedures are established. Add comments to code.
6. **Submit:** Push changes with clear commit messages.

By following these guidelines, we can collaboratively enhance this AI-powered troubleshooting assistant.
