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
30 10 * * * /Users/cesarangulo/Documents/github-activity-bot/scripts/github_activity_automation.sh
```

## Setup

1. Clone this repository
2. Ensure GitHub CLI is installed and authenticated
3. Make scripts executable: `chmod +x scripts/*.sh`
4. Install cron job: `crontab github_automation.cron`

## Logs

- `automation.log` - Detailed automation logs
- `cron.log` - Cron execution logs

---

*This repository is automatically maintained to ensure consistent GitHub activity.*
