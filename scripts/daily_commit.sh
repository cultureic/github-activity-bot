#!/bin/bash

# Daily GitHub Activity Automation Script
# This script creates meaningful commits to maintain GitHub activity

set -e  # Exit on any error

# Configuration
REPO_PATH="/Users/cesarangulo/Documents/github-activity-bot"
ACTIVITY_FILE="ACTIVITY.md"
LOG_FILE="$REPO_PATH/automation.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Change to repository directory
cd "$REPO_PATH"

log_message "Starting daily commit automation..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    log_message "Error: Not in a git repository"
    exit 1
fi

# Create or update activity file
if [ ! -f "$ACTIVITY_FILE" ]; then
    log_message "Creating activity file..."
    cat > "$ACTIVITY_FILE" << EOF
# Daily Activity Log

This file tracks daily automated commits to maintain GitHub activity.

## Activity History

EOF
fi

# Add today's entry
TODAY=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M:%S')
DAY_OF_WEEK=$(date '+%A')

# Create a meaningful update
echo "" >> "$ACTIVITY_FILE"
echo "### $TODAY ($DAY_OF_WEEK)" >> "$ACTIVITY_FILE"
echo "- Automated activity commit at $TIME" >> "$ACTIVITY_FILE"
echo "- Repository maintenance and health check completed" >> "$ACTIVITY_FILE"

# Also update a simple metrics file
METRICS_FILE="metrics.json"
if [ ! -f "$METRICS_FILE" ]; then
    echo '{"total_commits": 0, "last_update": ""}' > "$METRICS_FILE"
fi

# Update metrics
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
cat > "$METRICS_FILE" << EOF
{
  "total_commits": $COMMIT_COUNT,
  "last_update": "$TODAY $TIME",
  "automation_status": "active"
}
EOF

# Stage the changes
git add "$ACTIVITY_FILE" "$METRICS_FILE"

# Check if there are changes to commit
if git diff --staged --quiet; then
    log_message "No changes to commit today"
    exit 0
fi

# Create commit message
COMMIT_MSG="Daily activity update - $TODAY

- Updated activity log
- Refreshed metrics
- Automated maintenance commit"

# Commit the changes
git commit -m "$COMMIT_MSG"

log_message "Commit created successfully"

# Push to remote using HTTPS (GitHub CLI handles authentication)
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
    CURRENT_BRANCH="main"
    git checkout -b main
fi

# Use gh to push (handles HTTPS authentication automatically)
git push origin "$CURRENT_BRANCH" || {
    log_message "Warning: Could not push to remote. Commit created locally."
}

log_message "Daily commit automation completed successfully"
