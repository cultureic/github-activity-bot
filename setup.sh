#!/bin/bash

# GitHub Activity Bot Setup Script
# This script sets up the cron job with dynamic paths

set -e

# Get the current script directory and repo path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_PATH="$SCRIPT_DIR"
AUTOMATION_SCRIPT="$SCRIPT_DIR/scripts/github_activity_automation.sh"

echo "🚀 Setting up GitHub Activity Bot..."
echo "Repository path: $REPO_PATH"
echo "Automation script: $AUTOMATION_SCRIPT"

# Verify the automation script exists
if [ ! -f "$AUTOMATION_SCRIPT" ]; then
    echo "❌ Error: Automation script not found at $AUTOMATION_SCRIPT"
    exit 1
fi

# Make sure all scripts are executable
chmod +x "$SCRIPT_DIR/scripts"/*.sh

# Create the crontab content with dynamic paths using template
CRON_FILE="$SCRIPT_DIR/github_automation_generated.cron"
TEMPLATE_FILE="$SCRIPT_DIR/crontab.template"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Error: Template file not found at $TEMPLATE_FILE"
    exit 1
fi

# Generate cron file from template, replacing placeholders with actual paths
sed "s|\[REPO_PATH\]|$REPO_PATH|g" "$TEMPLATE_FILE" > "$CRON_FILE"

echo "📄 Generated cron configuration: $CRON_FILE"

# Ask user if they want to install the cron job
echo ""
echo "⚠️  This will replace your current crontab. Current crontab contents:"
echo "----------------------------------------"
crontab -l 2>/dev/null || echo "No existing crontab found."
echo "----------------------------------------"
echo ""

read -p "Do you want to install the cron job? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Install the cron job
    crontab "$CRON_FILE"
    echo "✅ Cron job installed successfully!"
    echo ""
    echo "📋 Current crontab:"
    crontab -l
else
    echo "⏸️  Cron job not installed. You can install it later by running:"
    echo "   crontab $CRON_FILE"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📖 Quick reference:"
echo "   • Test automation: $AUTOMATION_SCRIPT"
echo "   • View logs: tail -f $REPO_PATH/automation.log"
echo "   • View cron logs: tail -f $REPO_PATH/cron.log"
echo "   • Edit cron: crontab -e"
echo "   • View cron: crontab -l"
echo ""
echo "The automation will run daily at 10:30 AM and create PRs every Monday."
echo "Enjoy your automated GitHub activity! 🤖✨"
