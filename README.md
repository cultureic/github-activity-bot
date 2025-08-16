# GitHub Activity Bot 🤖

An automated system to maintain GitHub activity through daily commits and weekly pull requests.

## Features

- **Daily Commits**: Automated daily commits to maintain contribution streaks
- **Weekly PRs**: Automated pull request creation every Monday
- **Activity Tracking**: Comprehensive logging and metrics
- **HTTPS Authentication**: Uses GitHub CLI for seamless authentication

## Files

- `ACTIVITY.md` - Daily activity log
- `metrics.json` - Repository metrics and stats
- `FEATURES.md` - Weekly feature updates
- `CHANGELOG.md` - Project changelog
- `.version` - Version tracking

## Scripts

- `scripts/daily_commit.sh` - Daily commit automation
- `scripts/weekly_pr.sh` - Weekly PR automation  
- `scripts/github_activity_automation.sh` - Master coordination script

## Cron Schedule

The automation runs daily at 10:30 AM via cron job:
```bash
30 10 * * * /path/to/your/repo/scripts/github_activity_automation.sh
```

*Note: The setup script automatically generates the correct paths for your system.*

## Setup

1. Clone this repository
2. Ensure GitHub CLI is installed and authenticated: `gh auth login`
3. Configure Git remote with token (for HTTPS authentication)
4. Run the setup script: `./setup.sh`

The setup script will:
- Generate cron configuration with dynamic paths (no hardcoded user paths)
- Make all scripts executable
- Install the cron job (with confirmation)

### Manual Setup (Alternative)

If you prefer manual setup:
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Install cron job
crontab github_automation_dynamic.cron
```

## Logs

- `automation.log` - Detailed automation logs
- `cron.log` - Cron execution logs

---

*This repository is automatically maintained to ensure consistent GitHub activity.*
