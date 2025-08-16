#!/bin/bash

# Activity Scanner Script
# Scans configured repositories for recent activity and generates daily summaries

set -e

# Get script directory and repo path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_PATH="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$REPO_PATH/config/repos.conf"
ACTIVITY_CACHE="$REPO_PATH/.activity_cache.json"
LOG_FILE="$REPO_PATH/automation.log"

# Function to log messages (sanitized for privacy)
log_message() {
    local message="$1"
    # Sanitize paths to remove personal information
    message=$(echo "$message" | sed "s|$HOME|~|g" | sed 's|/Users/[^/]*/|/Users/USERNAME/|g')
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SCANNER: $message" | tee -a "$LOG_FILE"
}

# Function to get git author email (to filter for user's commits)
get_git_user_email() {
    git config --global user.email 2>/dev/null || echo ""
}

# Function to scan a single repository for today's activity
scan_repository() {
    local repo_path="$1"
    local today=$(date '+%Y-%m-%d')
    local user_email=$(get_git_user_email)
    
    if [ ! -d "$repo_path/.git" ]; then
        return 0
    fi
    
    cd "$repo_path"
    
    # Get repository name
    local repo_name=$(basename "$repo_path")
    
    # Get today's commits by the user
    local commits_today=""
    if [ -n "$user_email" ]; then
        commits_today=$(git log --oneline --since="$today 00:00:00" --until="$today 23:59:59" --author="$user_email" 2>/dev/null || echo "")
    else
        commits_today=$(git log --oneline --since="$today 00:00:00" --until="$today 23:59:59" 2>/dev/null || echo "")
    fi
    
    # Count commits
    local commit_count=0
    if [ -n "$commits_today" ]; then
        commit_count=$(echo "$commits_today" | wc -l | xargs)
    fi
    
    # Get files changed today
    local files_changed=""
    if [ -n "$user_email" ]; then
        files_changed=$(git log --name-only --since="$today 00:00:00" --until="$today 23:59:59" --author="$user_email" --pretty=format: 2>/dev/null | sort -u | grep -v '^$' || echo "")
    else
        files_changed=$(git log --name-only --since="$today 00:00:00" --until="$today 23:59:59" --pretty=format: 2>/dev/null | sort -u | grep -v '^$' || echo "")
    fi
    
    # Count different file types
    local js_files=$(echo "$files_changed" | grep -E '\.(js|jsx|ts|tsx)$' | wc -l | xargs)
    local py_files=$(echo "$files_changed" | grep -E '\.py$' | wc -l | xargs)
    local rs_files=$(echo "$files_changed" | grep -E '\.rs$' | wc -l | xargs)
    local go_files=$(echo "$files_changed" | grep -E '\.go$' | wc -l | xargs)
    local sol_files=$(echo "$files_changed" | grep -E '\.sol$' | wc -l | xargs)
    local md_files=$(echo "$files_changed" | grep -E '\.md$' | wc -l | xargs)
    local config_files=$(echo "$files_changed" | grep -E '\.(json|yaml|yml|toml|conf)$' | wc -l | xargs)
    
    # Get current branch
    local current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    # Get recent commit messages (last 3)
    local recent_messages=""
    if [ -n "$user_email" ]; then
        recent_messages=$(git log -3 --oneline --since="$today 00:00:00" --author="$user_email" --pretty=format:"%s" 2>/dev/null || echo "")
    else
        recent_messages=$(git log -3 --oneline --since="$today 00:00:00" --pretty=format:"%s" 2>/dev/null || echo "")
    fi
    
    # Output JSON for this repository
    cat << EOF
    {
        "repo": "$repo_name",
        "path": "$repo_path",
        "commits_today": $commit_count,
        "current_branch": "$current_branch",
        "file_changes": {
            "total": $(echo "$files_changed" | wc -l | xargs),
            "javascript": $js_files,
            "python": $py_files,
            "rust": $rs_files,
            "go": $go_files,
            "solidity": $sol_files,
            "markdown": $md_files,
            "config": $config_files
        },
        "recent_commits": [
$(echo "$commits_today" | head -3 | sed 's/.*/"&"/' | paste -sd ',' -)
        ],
        "recent_messages": [
$(echo "$recent_messages" | sed 's/.*/"&"/' | paste -sd ',' -)
        ]
    }
EOF
}

# Function to read repositories from config file
get_monitored_repos() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log_message "Config file not found: $CONFIG_FILE"
        return 1
    fi
    
    # Read non-comment, non-empty lines from config
    grep -v '^#' "$CONFIG_FILE" | grep -v '^[[:space:]]*$' || echo ""
}

# Function to generate activity summary
generate_activity_summary() {
    local today=$(date '+%Y-%m-%d')
    local total_commits=0
    local active_repos=0
    local languages_used=""
    local summary_text=""
    
    # Only log to file, not stdout when called for summary
    if [ "${1:-}" != "silent" ]; then
        log_message "Starting daily activity scan..." >&2
    fi
    
    # Create temporary file for JSON data
    local temp_json=$(mktemp)
    echo '{"date": "'$today'", "repositories": [' > "$temp_json"
    
    local first_repo=true
    
    # Scan each configured repository
    while IFS= read -r repo_path; do
        if [ -z "$repo_path" ]; then
            continue
        fi
        
        # Expand tilde to home directory
        repo_path=$(eval echo "$repo_path")
        
        if [ -d "$repo_path" ]; then
            # Log to stderr to avoid mixing with output
            if [ "${1:-}" != "silent" ]; then
                log_message "Scanning repository: $repo_path" >&2
            fi
            
            if [ "$first_repo" = false ]; then
                echo "," >> "$temp_json"
            fi
            
            scan_repository "$repo_path" >> "$temp_json"
            first_repo=false
            
            # Count activity
            cd "$repo_path"
            local commits_count=$(git log --oneline --since="$today 00:00:00" --until="$today 23:59:59" 2>/dev/null | wc -l | xargs)
            if [ "$commits_count" -gt 0 ]; then
                total_commits=$((total_commits + commits_count))
                active_repos=$((active_repos + 1))
            fi
        else
            if [ "${1:-}" != "silent" ]; then
                log_message "Repository not found: $repo_path" >&2
            fi
        fi
    done < <(get_monitored_repos)
    
    echo ']}' >> "$temp_json"
    
    # Save to cache
    cp "$temp_json" "$ACTIVITY_CACHE"
    
    # Generate human-readable summary
    if [ $total_commits -gt 0 ]; then
        summary_text="Active day: $total_commits commits across $active_repos repositories"
        
        # Add specific details
        if [ $active_repos -eq 1 ]; then
            local repo_name=$(jq -r '.repositories[0].repo' "$ACTIVITY_CACHE")
            local branch_name=$(jq -r '.repositories[0].current_branch' "$ACTIVITY_CACHE")
            summary_text="$summary_text. Working on $repo_name ($branch_name branch)"
        fi
        
        # Add file type information
        local total_js=$(jq '[.repositories[].file_changes.javascript] | add' "$ACTIVITY_CACHE")
        local total_py=$(jq '[.repositories[].file_changes.python] | add' "$ACTIVITY_CACHE")
        local total_rs=$(jq '[.repositories[].file_changes.rust] | add' "$ACTIVITY_CACHE")
        local total_go=$(jq '[.repositories[].file_changes.go] | add' "$ACTIVITY_CACHE")
        
        local lang_summary=""
        [ "$total_js" -gt 0 ] && lang_summary="${lang_summary}JS/TS ($total_js files) "
        [ "$total_py" -gt 0 ] && lang_summary="${lang_summary}Python ($total_py files) "
        [ "$total_rs" -gt 0 ] && lang_summary="${lang_summary}Rust ($total_rs files) "
        [ "$total_go" -gt 0 ] && lang_summary="${lang_summary}Go ($total_go files) "
        
        
        if [ -n "$lang_summary" ]; then
            summary_text="$summary_text. Languages: $lang_summary"
        fi
    else
        summary_text="Quiet day - maintaining streak with automated commit"
    fi
    
    # Output clean summary without log messages
    echo "$summary_text"
    
    # Cleanup
    rm "$temp_json"
}

# Function to get recent project context
get_project_context() {
    if [ ! -f "$ACTIVITY_CACHE" ]; then
        echo ""
        return
    fi
    
    # Extract recent commit messages for context
    local context=$(jq -r '.repositories[].recent_messages[]' "$ACTIVITY_CACHE" 2>/dev/null | head -5 | sed 's/^/- /' || echo "")
    
    if [ -n "$context" ]; then
        echo "Recent work context:"$'\n'"$context"
    fi
}

# Main execution
case "${1:-summary}" in
    "summary")
        generate_activity_summary
        ;;
    "context")
        get_project_context
        ;;
    "cache")
        if [ -f "$ACTIVITY_CACHE" ]; then
            jq . "$ACTIVITY_CACHE"
        else
            echo "No activity cache found"
        fi
        ;;
    *)
        echo "Usage: $0 [summary|context|cache]"
        echo "  summary - Generate daily activity summary (default)"
        echo "  context - Get recent project context"
        echo "  cache   - Display cached activity data"
        exit 1
        ;;
esac
