# Real Activity Tracking 📊

The GitHub Activity Bot now includes advanced real activity tracking that monitors your actual daily coding work across multiple repositories and integrates this information into your automated commits.

## Features

### 🔍 **Multi-Repository Scanning**
- Monitors multiple repositories simultaneously
- Tracks commits, file changes, and languages used
- Filters activity by your git user email
- Captures branch information and project context

### 📈 **Intelligent Summaries**
- Generates human-readable daily activity summaries
- Counts commits across all monitored repositories
- Identifies programming languages you worked with
- Provides project-specific context and recent work

### 🎯 **Smart Integration**
- Combines real activity data with creative commit messages
- Updates activity log with actual coding work
- Maintains streak with meaningful content
- Preserves context of your daily development work

## Configuration

### Repository Setup
Edit `config/repos.conf` to specify which repositories to monitor:

```bash
# Add your repository paths (one per line)
/Users/username/Documents/project1
/Users/username/Documents/project2
/Users/username/Documents/work/important-repo
```

**Note**: The config file supports:
- Full absolute paths
- Tilde expansion (`~/Documents/repo`)
- Comments (lines starting with #)
- Empty lines (ignored)

### Example Output

When you have real activity, the bot generates summaries like:

```
Active day: 11 commits across 1 repositories. Working on ckPayment (stage-2-wl branch). Languages: JS/TS (44 files) Python (1 files) Rust (4 files)
```

On quiet days:
```
Quiet day - maintaining streak with automated commit
```

## Activity Log Format

Your `ACTIVITY.md` file will now include:

```markdown
### 2025-08-16 (Saturday)
- Automated activity commit at 04:37:48
- **Daily Summary:** Active day: 11 commits across 1 repositories. Working on ckPayment (stage-2-wl branch). Languages: JS/TS (44 files) Python (1 files) Rust (4 files)
- **Recent Work:**
  Recent work context:
  - Daily activity update - 2025-08-16
  - cleanup: remove deprecated files and components
  - tools: add deployment scripts and optimized WASM files
- Repository maintenance and health check completed
```

## Scripts

### `scripts/activity_scanner.sh`
Main activity scanning script with three modes:

```bash
# Generate daily activity summary
./scripts/activity_scanner.sh summary

# Get recent project context
./scripts/activity_scanner.sh context

# View cached activity data (JSON)
./scripts/activity_scanner.sh cache
```

### Integration
The scanner is automatically called by `daily_commit.sh` and integrates seamlessly with your existing automation.

## Data Collection

### What's Tracked
- ✅ Commits made today by your git user
- ✅ Files modified (by type: JS/TS, Python, Rust, Go, etc.)
- ✅ Current working branches
- ✅ Recent commit messages for context
- ✅ Repository names and activity levels

### What's NOT Tracked
- ❌ Private repository contents
- ❌ Sensitive code or data
- ❌ Personal information beyond git user email
- ❌ File contents (only filenames and counts)

### Privacy
- All data stays on your local machine
- Activity cache (`.activity_cache.json`) is excluded from git
- Only summary information is included in commits
- No sensitive project details are exposed

## File Types Detected

| Extension | Category |
|-----------|----------|
| `.js`, `.jsx`, `.ts`, `.tsx` | JavaScript/TypeScript |
| `.py` | Python |
| `.rs` | Rust |
| `.go` | Go |
| `.sol` | Solidity |
| `.md` | Markdown/Documentation |
| `.json`, `.yaml`, `.yml`, `.toml`, `.conf` | Configuration |

## Benefits

### 🎯 **Authentic Activity**
- Your automated commits now reflect real work
- Provides meaningful context about your coding day
- Shows actual languages and projects you worked on

### 📊 **Better Insights**
- Track your daily coding patterns
- See which repositories you're most active in
- Understand your language usage over time

### 🤖 **Seamless Integration**
- Works automatically with existing cron jobs
- No manual intervention required
- Combines with creative commit messages for natural look

## Troubleshooting

### No Activity Detected
- Check that repository paths in `config/repos.conf` are correct
- Verify git user email is configured: `git config --global user.email`
- Ensure repositories have recent commits

### Scanner Errors
- Check automation.log for detailed error messages
- Verify jq is installed for JSON processing: `brew install jq`
- Ensure all repository paths are accessible

### Configuration Issues
- Repository paths must be absolute paths
- Use forward slashes even on Windows
- Remove any trailing slashes from paths

---

*This feature makes your GitHub activity bot much more authentic by incorporating your actual daily coding work!* 🚀
