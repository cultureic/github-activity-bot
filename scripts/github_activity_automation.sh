#!/bin/bash

# GitHub Activity Automation Master Script
# This script coordinates daily commits and weekly PRs

set -e  # Exit on any error

# Use dynamic paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_PATH="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$REPO_PATH/automation.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] MAIN: $1" | tee -a "$LOG_FILE"
}

log_message "Starting GitHub activity automation..."

# Always run daily commit
log_message "Running daily commit automation..."
"$SCRIPT_DIR/daily_commit.sh"

# Check if it's Monday (day 1) to run weekly PR
DAY_OF_WEEK=$(date '+%u')
if [ "$DAY_OF_WEEK" -eq 1 ]; then
    log_message "Monday detected - running weekly PR automation..."
    "$SCRIPT_DIR/weekly_pr.sh"
else
    log_message "Not Monday (day $DAY_OF_WEEK) - skipping weekly PR automation"
fi

log_message "GitHub activity automation completed successfully"
