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

# Create the crontab content with dynamic paths
CRON_FILE="$SCRIPT_DIR/github_automation_dynamic.cron"

cat > "$CRON_FILE" << EOF
# GitHub Activity Automation Cron Jobs
# This crontab runs daily commits and weekly PRs to maintain GitHub activity
# Generated automatically with dynamic paths

# Set PATH to ensure all commands are available
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Run GitHub activity automation daily at 10:30 AM
30 10 * * * $AUTOMATION_SCRIPT >> $REPO_PATH/cron.log 2>&1

# Optional: Alternative schedules (commented out)
# Run at 2:30 PM instead:
# 30 14 * * * $AUTOMATION_SCRIPT >> $REPO_PATH/cron.log 2>&1

# Run at 9:15 AM instead:
# 15 9 * * * $AUTOMATION_SCRIPT >> $REPO_PATH/cron.log 2>&1

# Weekly cleanup - remove old log entries on Sundays at 11 PM
0 23 * * 0 find $REPO_PATH -name "*.log" -exec tail -n 1000 {} \\; > /tmp/temp_log && mv /tmp/temp_log $REPO_PATH/automation.log
EOF

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
