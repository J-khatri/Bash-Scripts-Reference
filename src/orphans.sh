#!/usr/bin/env bash

# Script Name: orphans.sh
# Description: This script displays processes that might be orphans, i.e. processes that have no parent process.
# Usage: `./orphans.sh`
# Example: `./orphans.sh` displays a list of processes that might be orphans.

# Temporary file
TMP_FILE=$(mktemp /tmp/processes.XXXXXX)

# Cleanup function
cleanup() {
    rm -f "$TMP_FILE"
}

# Error handling function
error_exit() {
    echo "$1" 1>&2
    cleanup
    exit 1
}

# Function to check for orphan processes
check_orphans() {
    # Get a list of all processes
    ps -eo ppid,pid,comm | sed 1d | awk '{print $1 " " $2}' > "$TMP_FILE"

    # Check if each process has a parent process
    while read -r line; do
        ppid=$(echo "$line" | awk '{print $1}')
        pid=$(echo "$line" | awk '{print $2}')
        if ! grep -q "$ppid" "$TMP_FILE"; then
            echo "Process $pid might be an orphan"
        fi
    done < "$TMP_FILE"
}

# Check if the temp file was created
if [[ ! -e "$TMP_FILE" ]]; then
    error_exit "Failed to create temporary file. Make sure you have the right permissions."
fi

# Set a trap for cleanup
trap cleanup EXIT

# Run the main function
check_orphans
