# AGENTS.md - Instructions for AI Agent Development

This document provides guidance for AI agents working on the Intelligent CI/CD Pipeline Troubleshooting Assistant project.

## Project Overview

The goal of this project is to create a GitHub Action that uses an AI-powered assistant to analyze failed builds or deployments and provide intelligent suggestions or remediations.

**Current State:**
- The GitHub Actions workflow (`.github/workflows/main.yml`) is set up.
- The Python script (`scripts/log_parser.py`) uses the **real OpenAI API** for log analysis.
- **Automated PR commenting** of AI suggestions is implemented.
- Terraform configurations (`terraform/`) for an EKS cluster and VPC are defined.
- The pipeline runs `terraform init`, `validate`, and `plan` but **does not deploy infrastructure**.
- Conceptual placeholders for Slack integration remain.

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

### 1. OpenAI Integration
- **Status: Implemented.**
- The `scripts/log_parser.py` script uses the `openai` Python library to interact with the OpenAI API (e.g., `gpt-3.5-turbo`).
- **Crucial Setup:** An `OPENAI_API_KEY` must be configured as a GitHub secret in the repository settings (`Settings > Secrets and variables > Actions`) for the AI analysis to work. The workflow passes this key to the script.
- **Prompts:** Initial prompts are defined in `scripts/log_parser.py`. These should be iteratively refined for better accuracy and more specific suggestions. Consider different prompts for different types of errors.

### 2. Terraform Deployment (Future - Optional)
- **Status: Plan/Validate Only.**
- The pipeline currently only runs `terraform plan` using the configurations in `terraform/`.
- The Terraform code is structured using local modules (`modules/network` and `modules/eks_cluster`) called by the root module. Refer to `terraform/README.md` for details on structure and usage.
- To enable actual deployment:
    1. **CRITICAL: Ensure AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`) are securely configured as GitHub secrets.**
    2. In `.github/workflows/main.yml`, the `env` sections for AWS credentials in `Terraform Init` and `Terraform Plan` steps are currently commented out. These would need to be enabled if the plan were to interact with an actual AWS account state.
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

### 3. Suggestion Delivery
- **PR Comments:**
    - **Status: Implemented.**
    - The GitHub Actions workflow (`.github/workflows/main.yml`) uses `peter-evans/create-or-update-comment@v4` to post suggestions on Pull Requests.
    - The `log_parser.py` script (with `--quiet` flag) outputs the suggestion to `stdout`, which is captured by the workflow and passed to the commenting action.
    - The workflow has `permissions: pull-requests: write` to allow this.
- **Slack Messages (Future):**
    - **Status: Not Implemented.**
    - To implement: Add `slack_sdk` to `scripts/requirements.txt`, configure `SLACK_BOT_TOKEN` and `SLACK_CHANNEL_ID` secrets, and add logic to `log_parser.py` or a new script to send messages. Update the GHA workflow to call this.

### 4. Log Capturing in Workflow
- The current workflow simulates log capture from a failed step by writing to `simulated_error_log.txt`. This is the current "standardized" path for failure logs.
- For real failures from other steps:
    - Ensure those steps output relevant logs to a known file (e.g., `failure_log.txt`) that can then be passed to `scripts/log_parser.py --log-file failure_log.txt --quiet`.
    - Alternatively, capture `stdout`/`stderr` from failing steps as strings (if not too large) and pass using `--log-string`.

### 5. Handling Large Log Files (OpenAI API Token Limits)
- OpenAI models have token limits (e.g., `gpt-3.5-turbo` often around 4k-16k tokens for prompt + completion). Very large logs can exceed this.
- **Current State:** The script sends the entire log content. This may fail for large logs.
- **Future Enhancements to Consider:**
    - **Truncation:** Implement smart truncation in `log_parser.py` (e.g., keep first N lines, last M lines, or lines around "error" keywords). Inform the user if logs were truncated.
    - **Summarization/Chunking:** For very large logs, split into chunks, summarize each with a cheaper/faster model or keyword extraction, then analyze the summary.
    - **Model Selection:** Use models with larger context windows (e.g., `gpt-3.5-turbo-16k`) if necessary, but be mindful of cost.
    - **Error Handling:** The script should gracefully handle API errors related to token limits and inform the user. (Basic API error handling is present, but specific token limit errors could be highlighted).

### 6. Testing
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
