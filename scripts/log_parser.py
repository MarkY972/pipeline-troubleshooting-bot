"""
AI-Powered Log Analyzer Script.

This script simulates parsing log files or log strings, analyzing them using a
(mocked) AI interface, and generating troubleshooting suggestions.
It's designed to be part of a CI/CD pipeline to help diagnose failures.

Key functionalities:
- Parses log data from a file or a direct string input.
- Simulates interaction with an AI model (OpenAI's API structure is mimicked).
- Generates contextual suggestions based on (simulated) log content.
- Can be integrated into GitHub Actions to analyze logs from failed steps.

Placeholder sections for actual OpenAI API calls and suggestion delivery mechanisms
(like PR comments or Slack messages) are included for future development.
"""
import os
import json
import argparse
import sys # For stderr
from openai import OpenAI, APIError, RateLimitError, AuthenticationError

# In a real scenario: from openai import OpenAI (after pip install openai)

# Helper function for verbose printing
def eprint(*args, **kwargs):
    """Prints to stderr."""
    print(*args, file=sys.stderr, **kwargs)


def analyze_logs_with_ai(log_content: str, api_key: str, quiet: bool = False) -> str:
    """
    Analyzes log content with an AI model using the OpenAI API.
    If quiet is True, informational prints go to stderr.
    """
    printer = eprint if quiet else print

    printer("\n--- AI Log Analysis ---")
    if not log_content:
        printer("No log content provided for AI analysis.")
        return "No specific suggestions: Log content was empty."

    if not api_key:
        printer("Error: OPENAI_API_KEY not provided. Cannot perform AI analysis.")
        return "AI Analysis skipped: OpenAI API key not available."

    printer("Log content received by AI analyzer (first 500 chars):")
    printer(log_content[:500] + "...\n" if len(log_content) > 500 else log_content)

    client = OpenAI(api_key=api_key)

    try:
        system_prompt = """You are an expert CI/CD Pipeline Troubleshooting Assistant. Your goal is to analyze the provided logs, identify potential errors or causes of failure, and suggest concise, actionable troubleshooting steps.

Focus on:
- Identifying specific error messages.
- Correlating errors with common root causes for technologies like Docker, Kubernetes, Terraform, GitHub Actions, and general application build/deployment issues.
- Providing clear, step-by-step suggestions for remediation.
- If possible, suggest commands to run or specific files to check.
- If the log is unclear or too short, state that more information might be needed but still try to offer general advice based on any discernible information.
- Keep your response focused on the technical problem and its solution.
- Please format your suggestions using Markdown. Use bullet points for actionable steps.
"""

        user_prompt_content = f"Here are the logs from a failed CI/CD pipeline step:\n\n```\n{log_content}\n```\n\nPlease analyze these logs and provide troubleshooting suggestions."

        prompt_messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt_content}
        ]

        printer(f"Sending request to OpenAI API with model: gpt-3.5-turbo")
        response = client.chat.completions.create(
            model="gpt-3.5-turbo", # Using a common, cost-effective model
            messages=prompt_messages,
            temperature=0.3 # Lower temperature for more focused and deterministic suggestions
        )

        suggestion = response.choices[0].message.content
        printer("AI Suggestion (from OpenAI API):")
        printer(suggestion) # This will go to stderr if quiet, stdout otherwise. For GHA, we print suggestion separately.
        return suggestion
    except AuthenticationError as e:
        printer(f"OpenAI API Authentication Error: {e}")
        return f"AI Analysis failed: Authentication error. Check your API key and organization ID."
    except RateLimitError as e:
        printer(f"OpenAI API Rate Limit Exceeded: {e}")
        return f"AI Analysis failed: Rate limit exceeded. Please try again later or check your usage."
    except APIError as e:
        printer(f"OpenAI API Error: {e}")
        return f"AI Analysis failed: An API error occurred. Status Code: {e.status_code}. Message: {e.message}"
    except Exception as e:
        printer(f"An unexpected error occurred during AI analysis: {e}")
        return f"Could not get AI suggestion due to an unexpected error: {e}"

def parse_log_file(file_path: str, quiet: bool = False) -> str:
    """
    Reads content from a log file.
    If quiet is True, informational prints go to stderr.
    """
    printer = eprint if quiet else print
    printer(f"Attempting to read log file: {file_path}")
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        printer(f"Successfully read {len(content)} characters from {file_path}")
        return content
    except FileNotFoundError:
        printer(f"Error: Log file not found at {file_path}")
        return ""
    except Exception as e:
        printer(f"Error reading log file {file_path}: {e}")
        return ""

def main():
    parser = argparse.ArgumentParser(description="Parse logs and provide AI-driven suggestions.")
    parser.add_argument("--log-file", type=str, help="Path to the log file to analyze.")
    parser.add_argument("--log-string", type=str, help="A string containing log data to analyze.")
    parser.add_argument("--quiet", action="store_true", help="Output only the AI suggestion to stdout. All other logs go to stderr.")

    args = parser.parse_args()

    log_content_to_analyze = ""

    if args.log_file:
        eprint(f"Log file argument provided: {args.log_file}") if not args.quiet else None
        log_content_to_analyze = parse_log_file(args.log_file, quiet=args.quiet)
    elif args.log_string:
        eprint("Log string argument provided.") if not args.quiet else None
        log_content_to_analyze = args.log_string
    else:
        eprint("No log file or log string provided. Simulating some default error log for demonstration.") if not args.quiet else None
        simulated_errors = [
            {"timestamp": "2023-10-27T10:00:00Z", "level": "ERROR", "message": "Failed to connect to database", "service": "auth-service"},
            {"timestamp": "2023-10-27T10:00:05Z", "level": "ERROR", "message": "NullPointerException in UserServlet", "service": "user-service"},
            {"timestamp": "2023-10-27T10:01:00Z", "level": "WARN", "message": "High latency detected for payment-gateway", "service": "checkout-service"}
        ]
        log_content_to_analyze = json.dumps(simulated_errors, indent=2)
        if not args.quiet:
            eprint("\nSimulated Log Data for AI Analysis:")
            eprint(log_content_to_analyze)

    if not log_content_to_analyze:
        (eprint("No log content available to analyze. Exiting.") if not args.quiet
         else print("Error: No log content available to analyze.")) # Print error to stdout if quiet
        return

    openai_api_key = os.getenv("OPENAI_API_KEY")
    if not openai_api_key and not args.quiet:
        eprint("Warning: OPENAI_API_KEY environment variable not set. AI analysis will be skipped or will fail.")

    ai_suggestion = analyze_logs_with_ai(log_content_to_analyze, api_key=openai_api_key, quiet=args.quiet)

    if args.quiet:
        print(ai_suggestion) # Only print the suggestion itself to stdout
    else:
        # If not quiet, print the full output with headers to stderr (or stdout if preferred for debugging)
        eprint("\n--- Final Output ---")
        eprint("AI-Generated Suggestion:")
        eprint(ai_suggestion)

    # Placeholder for delivering suggestions (e.g., PR comment, Slack)
    # For now, we just print. In a GitHub Action, the workflow can capture the script's
    # standard output and set it as a step output.
    # For example, if this script prints the suggestion to stdout, a GHA step could do:
    #   suggestion_output=$(python scripts/log_parser.py --log-file some_log.txt)
    #   echo "suggestion=${suggestion_output}" >> $GITHUB_OUTPUT
    # This captured 'suggestion' output can then be used by subsequent steps.

    # --- Conceptual Suggestion Delivery ---
    # 1. GitHub PR Comment:
    #    - The GitHub Action workflow would need a step using an action like `peter-evans/create-or-update-comment`.
    #    - This step would take the `ai_suggestion` (output from the log parser script) as input.
    #    - Requires GITHUB_TOKEN with `pull-requests: write` permission.
    #    - Example workflow snippet:
    #      ```yaml
    #      - name: Post AI Suggestion to PR
    #        if: github.event_name == 'pull_request' && steps.ai_analysis.outputs.suggestion
    #        uses: peter-evans/create-or-update-comment@v3
    #        with:
    #          issue-number: ${{ github.event.pull_request.number }}
    #          body: |
    #            **AI Troubleshooting Assistant Suggests:**
    #            ${{ steps.ai_analysis.outputs.suggestion }}
    #      ```

    # 2. Slack Message:
    #    - The Python script could be extended with a function to send a message to Slack using `slack_sdk`.
    #    - Requires a Slack Bot Token stored as a GitHub secret (e.g., SLACK_BOT_TOKEN).
    #    - Requires the `slack_sdk` pip package.
    #    - Example Python function (conceptual):
    #      ```python
    #      # from slack_sdk import WebClient
    #      # from slack_sdk.errors import SlackApiError
    #      #
    #      # def send_slack_notification(channel, message, token):
    #      #     try:
    #      #         client = WebClient(token=token)
    #      #         response = client.chat_postMessage(channel=channel, text=message)
    #      #         print("Slack message sent successfully")
    #      #     except SlackApiError as e:
    #      #         print(f"Error sending Slack message: {e.response['error']}")
    #      #
    #      # # In main():
    #      # if os.getenv("SEND_SLACK_NOTIFICATION") == "true":
    #      #    slack_token = os.getenv("SLACK_BOT_TOKEN")
    #      #    slack_channel = os.getenv("SLACK_CHANNEL_ID", "#general")
    #      #    if slack_token:
    #      #        send_slack_notification(slack_channel, f"AI Suggestion: {ai_suggestion}", slack_token)
    #      #    else:
    #      #        print("SLACK_BOT_TOKEN not set. Skipping Slack notification.")
    #      ```
    #    - The GitHub Action workflow would need to set SEND_SLACK_NOTIFICATION, SLACK_BOT_TOKEN, SLACK_CHANNEL_ID env vars.

if __name__ == "__main__":
    main()
