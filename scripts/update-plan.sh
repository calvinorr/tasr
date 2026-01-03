#!/bin/bash
# update-plan.sh - Auto-update plan.md with commit hashes
# Called by post-commit hook to log commit hashes next to completed tasks
# Usage: ./update-plan.sh [TARS_ROOT]

set -e

TARS_ROOT="${1:-.}"

# Find active track from state file
STATE_FILE="$TARS_ROOT/.claude/tars-state.json"
if [ ! -f "$STATE_FILE" ]; then
    # No state file, skip silently (not a TARS-managed project)
    exit 0
fi

# Extract active track
ACTIVE_TRACK=$(grep -o '"activeTrack"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" | sed 's/.*: *"//' | sed 's/"$//')
TRACK_TYPE=$(grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" | sed 's/.*: *"//' | sed 's/"$//' || echo "standard")

if [ -z "$ACTIVE_TRACK" ]; then
    exit 0
fi

# Determine plan file location
if [ "$TRACK_TYPE" = "quick" ]; then
    PLAN_FILE="$TARS_ROOT/tars/tracks/quick/$ACTIVE_TRACK.md"
else
    PLAN_FILE="$TARS_ROOT/tars/tracks/$ACTIVE_TRACK/plan.md"
fi

if [ ! -f "$PLAN_FILE" ]; then
    exit 0
fi

# Get the last commit hash (short)
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || exit 0)
COMMIT_MSG=$(git log -1 --format="%s" 2>/dev/null | head -c 50)

# Find completed tasks without commit hashes and add the hash
# Pattern: - [x] Task text <!-- commit: -->
# Replace with: - [x] Task text <!-- commit: abc1234 -->

TEMP_FILE=$(mktemp)

while IFS= read -r line; do
    if [[ "$line" =~ ^\s*-\ \[x\].*\<!--\ commit:\ --\> ]]; then
        # This is a completed task without a commit hash - add the hash
        echo "$line" | sed "s/<!-- commit: -->/<!-- commit: $COMMIT_HASH -->/"
    else
        echo "$line"
    fi
done < "$PLAN_FILE" > "$TEMP_FILE"

# Only update if changes were made
if ! diff -q "$PLAN_FILE" "$TEMP_FILE" > /dev/null 2>&1; then
    mv "$TEMP_FILE" "$PLAN_FILE"
    echo "TARS: Updated plan.md with commit $COMMIT_HASH"
else
    rm "$TEMP_FILE"
fi
