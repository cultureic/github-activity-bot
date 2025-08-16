#!/bin/bash

# Privacy Filter Utility
# Sanitizes sensitive information from logs and outputs

# Function to sanitize sensitive information
sanitize_output() {
    local input="$1"
    
    # Get current user info for sanitization
    local current_user=$(whoami)
    local home_dir="$HOME"
    
    # Sanitize the input
    echo "$input" | \
        sed "s|$home_dir|~|g" | \
        sed "s|/Users/$current_user|/Users/USERNAME|g" | \
        sed "s|/home/$current_user|/home/USERNAME|g" | \
        sed 's|/Users/[^/]*/|/Users/USERNAME/|g' | \
        sed 's|/home/[^/]*/|/home/USERNAME/|g' | \
        sed "s|$current_user|USERNAME|g" | \
        sed 's|[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,\}|EMAIL@example.com|g'
}

# Function to sanitize file content
sanitize_file() {
    local file_path="$1"
    if [ -f "$file_path" ]; then
        local temp_file=$(mktemp)
        sanitize_output "$(cat "$file_path")" > "$temp_file"
        mv "$temp_file" "$file_path"
        echo "Sanitized: $file_path"
    fi
}

# Function to sanitize logs
sanitize_logs() {
    local repo_path="$1"
    
    # Sanitize automation log
    if [ -f "$repo_path/automation.log" ]; then
        sanitize_file "$repo_path/automation.log"
    fi
    
    # Sanitize cron log
    if [ -f "$repo_path/cron.log" ]; then
        sanitize_file "$repo_path/cron.log"
    fi
    
    echo "Log sanitization completed"
}

# Main execution
case "${1:-help}" in
    "output")
        sanitize_output "$2"
        ;;
    "file")
        sanitize_file "$2"
        ;;
    "logs")
        sanitize_logs "${2:-$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")}"
        ;;
    "help"|*)
        echo "Privacy Filter Utility"
        echo "Usage: $0 [output|file|logs|help] [parameter]"
        echo ""
        echo "Commands:"
        echo "  output <text>  - Sanitize text output"
        echo "  file <path>    - Sanitize file content"
        echo "  logs [path]    - Sanitize log files in directory"
        echo "  help           - Show this help"
        echo ""
        echo "This utility removes sensitive information like:"
        echo "  - Personal usernames and paths"
        echo "  - Email addresses"
        echo "  - Home directory paths"
        exit 0
        ;;
esac
