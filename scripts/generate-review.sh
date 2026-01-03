#!/bin/bash
# generate-review.sh - Generate visual review HTML from plan.md
#
# Usage: ./generate-review.sh <project_root> [track_id]
# Output: Creates review.html in the track folder
#
# If track_id not provided, reads from .claude/tars-state.json

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="${1:-.}"
TRACK_ID="$2"

# Resolve project root to absolute path
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

# Get track ID from state if not provided
if [ -z "$TRACK_ID" ]; then
  STATE_FILE="$PROJECT_ROOT/.claude/tars-state.json"
  if [ -f "$STATE_FILE" ]; then
    TRACK_ID=$(grep -o '"activeTrack": *"[^"]*"' "$STATE_FILE" | sed 's/.*: *"//' | sed 's/"//')
  fi
fi

if [ -z "$TRACK_ID" ] || [ "$TRACK_ID" = "null" ]; then
  echo "Error: No active track. Provide track_id or set activeTrack in tars-state.json" >&2
  exit 1
fi

# Determine paths
TRACK_DIR="$PROJECT_ROOT/tars/tracks/$TRACK_ID"
PLAN_FILE="$TRACK_DIR/plan.md"
OUTPUT_FILE="$TRACK_DIR/review.html"

# Check for quick track
if [ ! -d "$TRACK_DIR" ]; then
  QUICK_FILE="$PROJECT_ROOT/tars/tracks/quick/$TRACK_ID.md"
  if [ -f "$QUICK_FILE" ]; then
    PLAN_FILE="$QUICK_FILE"
    OUTPUT_FILE="$PROJECT_ROOT/tars/tracks/quick/$TRACK_ID-review.html"
  else
    echo "Error: Track not found: $TRACK_ID" >&2
    exit 1
  fi
fi

if [ ! -f "$PLAN_FILE" ]; then
  echo "Error: Plan file not found: $PLAN_FILE" >&2
  exit 1
fi

# Find template
TEMPLATE_FILE="$PROJECT_ROOT/templates/plan-review.html"
if [ ! -f "$TEMPLATE_FILE" ]; then
  # Try user-level location
  TEMPLATE_FILE="$HOME/.claude/tars/templates/plan-review.html"
fi
if [ ! -f "$TEMPLATE_FILE" ]; then
  # Try script directory sibling
  TEMPLATE_FILE="$SCRIPT_DIR/../templates/plan-review.html"
fi
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Error: Template not found. Expected at:" >&2
  echo "  - $PROJECT_ROOT/templates/plan-review.html" >&2
  echo "  - ~/.claude/tars/templates/plan-review.html" >&2
  exit 1
fi

echo "Generating review HTML..."
echo "  Track: $TRACK_ID"
echo "  Plan: $PLAN_FILE"
echo "  Output: $OUTPUT_FILE"

# Generate JSON from plan
PLAN_JSON=$("$SCRIPT_DIR/plan-to-json.sh" "$PLAN_FILE")

# Escape JSON for JavaScript embedding (handle newlines, quotes)
PLAN_JSON_ESCAPED=$(echo "$PLAN_JSON" | tr '\n' ' ' | sed 's/  */ /g')

# Read template and inject data
# Replace placeholders in template
sed -e "s|{{TRACK_ID}}|$TRACK_ID|g" \
    -e "s|{{TRACK_NAME}}|$TRACK_ID|g" \
    "$TEMPLATE_FILE" > "$OUTPUT_FILE.tmp"

# Inject the phases array into PLAN_DATA
# Find the line with phases: [] and replace it
awk -v json="$PLAN_JSON_ESCAPED" '
  /const PLAN_DATA = \{/ {
    print "    const PLAN_DATA = " json ";"
    skip = 1
    next
  }
  skip && /};/ {
    skip = 0
    next
  }
  !skip { print }
' "$OUTPUT_FILE.tmp" > "$OUTPUT_FILE"

rm -f "$OUTPUT_FILE.tmp"

echo "Done! Review file created at: $OUTPUT_FILE"
echo ""
echo "Open in browser or use Claude-in-Chrome to navigate to:"
echo "  file://$OUTPUT_FILE"
