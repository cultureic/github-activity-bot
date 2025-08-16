#!/bin/bash

# Daily GitHub Activity Automation Script
# This script creates meaningful commits to maintain GitHub activity

set -e  # Exit on any error

# Configuration - Use dynamic paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_PATH="$(dirname "$SCRIPT_DIR")"
ACTIVITY_FILE="ACTIVITY.md"
LOG_FILE="$REPO_PATH/automation.log"

# Function to log messages (with privacy protection)
log_message() {
    local message="$1"
    # Sanitize sensitive information from logs
    message=$(echo "$message" | sed "s|$HOME|~|g" | sed 's|/Users/[^/]*/|/Users/USERNAME/|g')
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
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

# Scan for real activity from other repositories
log_message "Scanning for daily activity across monitored repositories..."
ACTIVITY_SUMMARY=$("$SCRIPT_DIR/activity_scanner.sh" summary 2>/dev/null)
log_message "Activity summary: $ACTIVITY_SUMMARY"

# Get project context
PROJECT_CONTEXT=$("$SCRIPT_DIR/activity_scanner.sh" context 2>/dev/null)

# Create a meaningful update with real activity data
echo "" >> "$ACTIVITY_FILE"
echo "### $TODAY ($DAY_OF_WEEK)" >> "$ACTIVITY_FILE"
echo "- Automated activity commit at $TIME" >> "$ACTIVITY_FILE"
echo "- **Daily Summary:** $ACTIVITY_SUMMARY" >> "$ACTIVITY_FILE"

if [ -n "$PROJECT_CONTEXT" ]; then
    echo "- **Recent Work:**" >> "$ACTIVITY_FILE"
    echo "$PROJECT_CONTEXT" | sed 's/^/  /' >> "$ACTIVITY_FILE"
fi

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

# Array of creative commit messages
COMMIT_MESSAGES=(
    "🌱 Daily growth commit"
    "🔥 Streak fuel"
    "⚡ Automagic update"
    "🛠️ chore(cron): daily streak"
    "📈 ci: streak heartbeat"
    "⏰ streak saver"
    "🚀 Pushing today's progress"
    "📌 GitHub streak alive"
    "🎯 Commit hit"
    "🌀 Daily loop complete"
    "📝 Tiny step forward"
    "💡 Idea placeholder commit"
    "💪 Consistency mode"
    "🐧 Linux-style daily push"
    "☕ Coffee-fueled streak"
    "🌙 Midnight streak saver"
    "🐙 Octocat happy"
    "🧩 Daily puzzle piece"
    "🎮 Leveling up streak"
    "✨ Spark for the streak"
    "🎶 Commit rhythm"
    "🚦 Daily checkpoint"
    "📚 Adding to history"
    "🌊 Another wave of code"
    "🐝 Busy bee commit"
    "🎉 Streak party"
    "🧑‍💻 Code heartbeat"
    "🔑 Unlocking streak day"
    "🛡️ Streak protected"
    "🌍 Global streak sync"
    "🎲 Random streak commit"
    "🏹 Arrow of progress"
    "🎇 Sparkler streak"
    "🏆 Daily win"
    "⛅ Cloud sync commit"
    "🛰️ Satellite ping"
    "⛓️ Chain unbroken"
    "🔒 Locking streak"
    "💫 Shooting star commit"
    "🌵 Desert streak survivor"
    "🔨 Building consistency"
    "🧭 Streak compass aligned"
    "🎤 Commit mic drop"
    "🍀 Lucky streak day"
    "🦉 Night owl streak"
    "🐦 Early bird streak"
    "🎈 Balloon push"
    "🧊 Ice-cool streak"
    "🔥🔥 Double fire streak"
    "🌸 Blossom streak"
    "🍂 Autumn vibe commit"
    "❄️ Winter streak"
    "☀️ Summer push"
    "🌧️ Rain or shine commit"
    "🐉 Dragon streak"
    "🦅 Flying high"
    "🐢 Slow but steady"
    "⚓ Anchored streak"
    "⛏️ Digging progress"
    "💎 Polishing streak gem"
    "🧙 Wizard commit"
    "🧛 Vampire streak"
    "👾 Pixel push"
    "🤖 Robot heartbeat"
    "🎬 Commit scene"
    "🎨 Brushstroke streak"
    "🥁 Daily drumbeat"
    "🧩 Puzzle snap"
    "🍕 Pizza commit"
    "🍫 Sweet streak"
    "🍩 Donut push"
    "🍎 Apple streak"
    "🌽 Kernel alive"
    "🍞 Daily bread commit"
    "🌮 Taco streak"
    "🥑 Avocado push"
    "🚲 Keep rolling"
    "🚗 Daily drive"
    "🚂 Train is on time"
    "✈️ Flying streak"
    "🚀 Rocket streak"
    "⛵ Sailing smoothly"
    "⚓ Docked today"
    "🏝️ Island commit"
    "🏔️ Mountain push"
    "🛤️ Tracks laid"
    "🏕️ Camping streak"
    "🐾 Daily footprint"
    "🦋 Butterfly streak"
    "🐠 Swimming along"
    "🦀 Crab walk commit"
    "🦈 Shark streak"
    "🐳 Whale push"
    "🦦 Otter streak"
    "🐊 Croc commit"
    "🦚 Peacock streak"
    "🐍 Snake alive"
    "🐒 Monkey streak"
    "🐕 Loyal streak"
    "🐱 Cat commit"
    "🦄 Unicorn streak"
    "🐉 Dragon breath commit"
    "🦋 Fluttering streak"
    "🪐 Planet aligned"
    "🌌 Cosmic streak"
    "🌠 Shooting commit"
    "🌞 Sun push"
    "🌝 Moon streak"
    "🌚 Dark mode streak"
    "🔭 Observed daily"
    "🛰️ Beacon ping"
    "🧭 Direction clear"
    "🕹️ Gamer streak"
    "🎮 Console commit"
    "🖲️ Trackball alive"
    "💾 Saved progress"
    "💻 Typing streak"
    "⌨️ Keyboard tap"
    "🖥️ Screen glow"
    "🖱️ Mouse click"
    "🎧 Music flow commit"
    "🎷 Jazzy streak"
    "🎸 Rock push"
    "🥁 Drum streak"
    "🎺 Horn commit"
    "🎻 Violin streak"
    "🕺 Commit dance"
    "💃 Daily groove"
    "🎮 Next level streak"
    "🧩 Fit another piece"
    "🧱 Brick in the wall"
    "🧗 Climbing streak"
    "🚧 Daily checkpoint"
    "🏗️ Streak scaffolding"
    "🛠️ Maintenance push"
    "🔧 Wrench commit"
    "⚙️ Gear moving"
    "🔩 Bolted streak"
    "🧲 Magnet pull"
    "🪛 Screwdriver streak"
    "🧵 Thread of progress"
    "🪡 Needle commit"
    "✂️ Snipping streak"
    "📏 Aligned today"
    "📐 Measured streak"
    "🖊️ Ink drop commit"
    "✏️ Pencil mark"
    "🖌️ Painted push"
    "🖍️ Crayon streak"
    "📝 Note saved"
)

# Select random commit message
RANDOM_INDEX=$((RANDOM % ${#COMMIT_MESSAGES[@]}))
COMMIT_TITLE="${COMMIT_MESSAGES[$RANDOM_INDEX]}"

# Create commit message with details
COMMIT_MSG="$COMMIT_TITLE

- Updated activity log for $TODAY
- Refreshed metrics and automation status
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
