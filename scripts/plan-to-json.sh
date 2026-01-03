#!/bin/bash
# plan-to-json.sh - Convert plan.md to JSON for visual review
#
# Usage: ./plan-to-json.sh <plan.md path>
# Output: JSON structure of phases and tasks

set -e

PLAN_FILE="$1"

if [ -z "$PLAN_FILE" ] || [ ! -f "$PLAN_FILE" ]; then
  echo "Usage: $0 <plan.md path>" >&2
  exit 1
fi

# Extract track ID from path (e.g., tars/tracks/feat-auth/plan.md -> feat-auth)
TRACK_ID=$(basename "$(dirname "$PLAN_FILE")")

# Extract track name from first # heading or use track ID
TRACK_NAME=$(grep -m1 "^# " "$PLAN_FILE" | sed 's/^# //' | sed 's/Plan: //' || echo "$TRACK_ID")

# Start JSON
echo "{"
echo "  \"trackId\": \"$TRACK_ID\","
echo "  \"trackName\": \"$TRACK_NAME\","
echo "  \"phases\": ["

# Parse phases and tasks
PHASE_COUNT=0
CURRENT_PHASE=""
FIRST_PHASE=true
IN_PHASE=false
TASK_BUFFER=""

while IFS= read -r line || [ -n "$line" ]; do
  # Check for phase header: ## Phase N: Name or just ## Name
  if echo "$line" | grep -qE "^## (Phase [0-9]+:|[A-Z])"; then
    # Close previous phase if exists
    if [ "$IN_PHASE" = true ]; then
      # Remove trailing comma from last task
      if [ -n "$TASK_BUFFER" ]; then
        echo "$TASK_BUFFER" | sed '$ s/,$//'
      fi
      echo "      ]"
      echo "    },"
    fi

    # Start new phase
    PHASE_NAME=$(echo "$line" | sed 's/^## //')
    PHASE_COUNT=$((PHASE_COUNT + 1))
    IN_PHASE=true
    TASK_BUFFER=""

    echo "    {"
    echo "      \"name\": \"$PHASE_NAME\","
    echo "      \"tasks\": ["
    continue
  fi

  # Check for task: - [ ] or - [x]
  if echo "$line" | grep -qE "^- \[([ x])\]"; then
    # Extract completion status
    if echo "$line" | grep -qE "^- \[x\]"; then
      COMPLETED="true"
    else
      COMPLETED="false"
    fi

    # Extract task text (after checkbox, before <!-- comment -->)
    TASK_TEXT=$(echo "$line" | sed 's/^- \[.\] //' | sed 's/ *<!-- commit:.*-->//')
    # Escape quotes for JSON
    TASK_TEXT=$(echo "$TASK_TEXT" | sed 's/"/\\"/g')

    # Extract commit hash if present
    if echo "$line" | grep -qE "<!-- commit: [a-f0-9]+ -->"; then
      COMMIT=$(echo "$line" | grep -oE "<!-- commit: [a-f0-9]+ -->" | sed 's/<!-- commit: //' | sed 's/ -->//')
    else
      COMMIT=""
    fi

    # Build task JSON
    TASK_JSON="        {"
    TASK_JSON="$TASK_JSON\"text\": \"$TASK_TEXT\","
    TASK_JSON="$TASK_JSON \"completed\": $COMPLETED"
    if [ -n "$COMMIT" ]; then
      TASK_JSON="$TASK_JSON, \"commit\": \"$COMMIT\""
    fi
    TASK_JSON="$TASK_JSON},"

    TASK_BUFFER="$TASK_BUFFER
$TASK_JSON"
  fi
done < "$PLAN_FILE"

# Close last phase
if [ "$IN_PHASE" = true ]; then
  if [ -n "$TASK_BUFFER" ]; then
    echo "$TASK_BUFFER" | sed '$ s/,$//'
  fi
  echo "      ]"
  echo "    }"
fi

echo "  ]"
echo "}"
