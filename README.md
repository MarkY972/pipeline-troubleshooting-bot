# Intelligent CI/CD Pipeline Troubleshooting Assistant

This project implements a GitHub Action that uses an AI-powered assistant to analyze failed builds or deployments and provide intelligent suggestions directly in Pull Request comments.

## Features

- **GitHub Actions Integration:** Triggers on push and pull requests to analyze CI/CD pipeline steps.
- **AI-Powered Log Analysis:** Utilizes OpenAI's GPT models (e.g., `gpt-3.5-turbo`) to analyze logs from failed steps.
- **Automated PR Comments:** Posts AI-generated troubleshooting suggestions directly as comments on the relevant Pull Request.
- **Terraform Infrastructure (Conceptual):** Includes Terraform configurations to define a sample EKS cluster. The CI pipeline runs `terraform plan` to validate these configurations but does not automatically deploy.
- **Python Scripting:** Core logic for log parsing and AI interaction is handled by a Python script.

## How It Works

1.  When a GitHub Actions workflow is triggered (e.g., by a PR), it executes its defined jobs.
2.  A (currently simulated) step in the workflow can "fail".
3.  Logs from this failed step are captured.
4.  The `scripts/log_parser.py` script is invoked, which sends these logs to the OpenAI API for analysis.
5.  The AI model returns troubleshooting suggestions.
6.  If the workflow was triggered by a Pull Request, these suggestions are posted as a comment on the PR.

## Setup

### Required Secrets

To use the AI analysis and PR commenting features, you **must** configure the following secrets in your GitHub repository (`Settings > Secrets and variables > Actions > New repository secret`):

1.  **`OPENAI_API_KEY`**: Your API key for OpenAI. This is required for the AI log analysis.

### Optional Secrets (for future Terraform deployment)

If you intend to extend the project to deploy the Terraform infrastructure, you will also need:

-   `AWS_ACCESS_KEY_ID`
-   `AWS_SECRET_ACCESS_KEY`
-   `AWS_DEFAULT_REGION` (or `AWS_REGION`)

Refer to `terraform/README.md` for more details on the Terraform setup.

## Usage

-   The primary interaction is through Pull Requests. If a (monitored) step in the CI pipeline fails, the assistant should automatically post a comment with suggestions.
-   The Terraform configurations can be planned and validated by the CI pipeline. See `terraform/README.md` for manual Terraform usage.

## Project Structure

-   `.github/workflows/main.yml`: Main GitHub Actions workflow.
-   `scripts/log_parser.py`: Python script for log parsing and OpenAI interaction.
-   `scripts/requirements.txt`: Python dependencies.
-   `terraform/`: Terraform configurations for sample AWS EKS infrastructure.
-   `AGENTS.md`: Guidelines for AI agents contributing to this project.

## Development

See `AGENTS.md` for detailed development guidelines, including how to:
-   Refine AI prompts.
-   Handle large log files.
-   Extend suggestion delivery mechanisms (e.g., Slack).
-   Enable actual Terraform deployment.

## Contributing

Contributions are welcome! Please refer to `AGENTS.md` and consider the existing project structure and goals.

---

*This project demonstrates AI-assisted DevOps workflows, log parsing, CI/CD debugging, and pipeline management concepts.*
