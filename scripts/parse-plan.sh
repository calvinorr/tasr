#!/bin/bash
# parse-plan.sh - Extract tasks from plan.md files
# Usage: ./parse-plan.sh [TARS_ROOT] [--summary|--json|--pending]

set -e

TARS_ROOT="${1:-.}"
MODE="${2:---summary}"

# Find active track from state file
STATE_FILE="$TARS_ROOT/.claude/tars-state.json"
if [ ! -f "$STATE_FILE" ]; then
    echo "Error: No tars-state.json found at $STATE_FILE"
    exit 1
fi

# Extract active track ID (basic JSON parsing with grep/sed)
ACTIVE_TRACK=$(grep -o '"activeTrack"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" | sed 's/.*: *"//' | sed 's/"$//')
TRACK_TYPE=$(grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" | sed 's/.*: *"//' | sed 's/"$//' || echo "standard")

if [ -z "$ACTIVE_TRACK" ]; then
    echo "Error: No active track found in state file"
    exit 1
fi

# Determine plan file location based on track type
if [ "$TRACK_TYPE" = "quick" ]; then
    PLAN_FILE="$TARS_ROOT/tars/tracks/quick/$ACTIVE_TRACK.md"
else
    PLAN_FILE="$TARS_ROOT/tars/tracks/$ACTIVE_TRACK/plan.md"
fi

if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: Plan file not found at $PLAN_FILE"
    exit 1
fi

# Count tasks
TOTAL=$(grep -c '^\s*- \[' "$PLAN_FILE" 2>/dev/null || echo 0)
COMPLETED=$(grep -c '^\s*- \[x\]' "$PLAN_FILE" 2>/dev/null || echo 0)
PENDING=$((TOTAL - COMPLETED))

case "$MODE" in
    --summary)
        echo "Track: $ACTIVE_TRACK"
        echo "Type: $TRACK_TYPE"
        echo "Plan: $PLAN_FILE"
        echo "---"
        echo "Total tasks: $TOTAL"
        echo "Completed: $COMPLETED"
        echo "Pending: $PENDING"
        echo "Progress: $((COMPLETED * 100 / (TOTAL > 0 ? TOTAL : 1)))%"
        echo "---"
        echo "Next pending tasks:"
        grep '^\s*- \[ \]' "$PLAN_FILE" | head -3 | sed 's/<!--.*-->//' | sed 's/^\s*- \[ \] /  - /'
        ;;
    --json)
        echo "{"
        echo "  \"track\": \"$ACTIVE_TRACK\","
        echo "  \"type\": \"$TRACK_TYPE\","
        echo "  \"total\": $TOTAL,"
        echo "  \"completed\": $COMPLETED,"
        echo "  \"pending\": $PENDING,"
        echo "  \"tasks\": ["

        # Extract tasks with their status
        FIRST=true
        while IFS= read -r line; do
            if [[ "$line" =~ ^\s*-\ \[(x|\ )\] ]]; then
                STATUS="pending"
                [[ "$line" =~ ^\s*-\ \[x\] ]] && STATUS="completed"
                # Extract task text and commit hash
                TASK=$(echo "$line" | sed 's/^\s*- \[[x ]\] //' | sed 's/<!--.*-->//' | sed 's/"/\\"/g')
                COMMIT=$(echo "$line" | grep -o '<!-- commit: [^>]*-->' | sed 's/<!-- commit: //' | sed 's/ -->//' || echo "")

                if [ "$FIRST" = true ]; then
                    FIRST=false
                else
                    echo ","
                fi
                printf '    {"status": "%s", "task": "%s", "commit": "%s"}' "$STATUS" "$TASK" "$COMMIT"
            fi
        done < "$PLAN_FILE"

        echo ""
        echo "  ]"
        echo "}"
        ;;
    --pending)
        echo "Pending tasks for $ACTIVE_TRACK:"
        grep '^\s*- \[ \]' "$PLAN_FILE" | sed 's/<!--.*-->//' | sed 's/^\s*- \[ \] /  - /'
        ;;
    *)
        echo "Usage: $0 [TARS_ROOT] [--summary|--json|--pending]"
        exit 1
        ;;
esac
