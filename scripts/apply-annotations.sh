#!/bin/bash
# apply-annotations.sh - Apply visual review annotations to plan.md
#
# Usage: ./apply-annotations.sh <project_root> '<annotations_json>'
#
# The annotations JSON should be the result.annotations object from the visual review.
# Example: ./apply-annotations.sh . '{"0-0":{"status":"approved"},"0-1":{"status":"deleted"}}'

set -e

PROJECT_ROOT="${1:-.}"
ANNOTATIONS_JSON="$2"

if [ -z "$ANNOTATIONS_JSON" ]; then
  echo "Usage: $0 <project_root> '<annotations_json>'" >&2
  exit 1
fi

# Resolve project root
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

# Get active track from state
STATE_FILE="$PROJECT_ROOT/.claude/hal-state.json"
if [ ! -f "$STATE_FILE" ]; then
  echo "Error: No hal-state.json found" >&2
  exit 1
fi

TRACK_ID=$(grep -o '"activeTrack": *"[^"]*"' "$STATE_FILE" | sed 's/.*: *"//' | sed 's/"//')
if [ -z "$TRACK_ID" ] || [ "$TRACK_ID" = "null" ]; then
  echo "Error: No active track" >&2
  exit 1
fi

# Determine plan file path
PLAN_FILE="$PROJECT_ROOT/hal/tracks/$TRACK_ID/plan.md"
if [ ! -f "$PLAN_FILE" ]; then
  # Check for quick track
  PLAN_FILE="$PROJECT_ROOT/hal/tracks/quick/$TRACK_ID.md"
fi

if [ ! -f "$PLAN_FILE" ]; then
  echo "Error: Plan file not found for track: $TRACK_ID" >&2
  exit 1
fi

echo "Applying annotations to: $PLAN_FILE"

# Create temp file for processing
TEMP_FILE=$(mktemp)
cp "$PLAN_FILE" "$TEMP_FILE"

# Parse annotations and apply changes
# We'll use a simple approach: process line by line, tracking phase and task indices

PHASE_IDX=-1
TASK_IDX=-1
OUTPUT_FILE=$(mktemp)
DELETED_COUNT=0
MODIFIED_COUNT=0
COMMENT_COUNT=0

while IFS= read -r line || [ -n "$line" ]; do
  # Check for phase header
  if echo "$line" | grep -qE "^## (Phase [0-9]+:|[A-Z])"; then
    PHASE_IDX=$((PHASE_IDX + 1))
    TASK_IDX=-1
    echo "$line" >> "$OUTPUT_FILE"
    continue
  fi

  # Check for task line
  if echo "$line" | grep -qE "^- \[([ x])\]"; then
    TASK_IDX=$((TASK_IDX + 1))
    TASK_KEY="${PHASE_IDX}-${TASK_IDX}"

    # Get annotation for this task
    # Extract status, modifiedText, comment from JSON
    STATUS=$(echo "$ANNOTATIONS_JSON" | grep -o "\"$TASK_KEY\":{[^}]*}" | grep -o '"status":"[^"]*"' | sed 's/.*:"//' | sed 's/"//' || echo "")
    MODIFIED_TEXT=$(echo "$ANNOTATIONS_JSON" | grep -o "\"$TASK_KEY\":{[^}]*}" | grep -o '"modifiedText":"[^"]*"' | sed 's/.*:"//' | sed 's/"//' || echo "")
    COMMENT=$(echo "$ANNOTATIONS_JSON" | grep -o "\"$TASK_KEY\":{[^}]*}" | grep -o '"comment":"[^"]*"' | sed 's/.*:"//' | sed 's/"//' || echo "")

    # Handle based on status
    case "$STATUS" in
      "deleted")
        # Skip this line (don't write to output)
        DELETED_COUNT=$((DELETED_COUNT + 1))
        echo "  Deleted: $TASK_KEY"
        continue
        ;;
      "modified")
        # Replace task text with modified version
        if [ -n "$MODIFIED_TEXT" ]; then
          # Preserve checkbox state and commit marker
          CHECKBOX=$(echo "$line" | grep -oE "^- \[([ x])\]")
          COMMIT_MARKER=$(echo "$line" | grep -oE "<!-- commit:[^>]*-->" || echo "<!-- commit: -->")
          echo "$CHECKBOX $MODIFIED_TEXT $COMMIT_MARKER" >> "$OUTPUT_FILE"
          MODIFIED_COUNT=$((MODIFIED_COUNT + 1))
          echo "  Modified: $TASK_KEY"
        else
          echo "$line" >> "$OUTPUT_FILE"
        fi
        ;;
      *)
        # Approved or pending - keep as is
        echo "$line" >> "$OUTPUT_FILE"
        ;;
    esac

    # Add comment if present
    if [ -n "$COMMENT" ] && [ "$COMMENT" != "" ]; then
      echo "  <!-- Review comment: $COMMENT -->" >> "$OUTPUT_FILE"
      COMMENT_COUNT=$((COMMENT_COUNT + 1))
      echo "  Comment added: $TASK_KEY"
    fi

    continue
  fi

  # Not a phase or task line - pass through
  echo "$line" >> "$OUTPUT_FILE"
done < "$TEMP_FILE"

# Replace original with updated
mv "$OUTPUT_FILE" "$PLAN_FILE"
rm -f "$TEMP_FILE"

echo ""
echo "Annotations applied:"
echo "  Deleted: $DELETED_COUNT tasks"
echo "  Modified: $MODIFIED_COUNT tasks"
echo "  Comments: $COMMENT_COUNT added"
echo ""
echo "Updated: $PLAN_FILE"
