#!/bin/bash
# install-hooks.sh - Install HAL git hooks in a project
# Usage: ./install-hooks.sh [PROJECT_PATH]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/../hooks"
PROJECT_PATH="${1:-.}"

# Resolve to absolute path
PROJECT_PATH=$(cd "$PROJECT_PATH" && pwd)

# Check if it's a git repository
if [ ! -d "$PROJECT_PATH/.git" ]; then
    echo "Error: $PROJECT_PATH is not a git repository"
    exit 1
fi

GIT_HOOKS_DIR="$PROJECT_PATH/.git/hooks"

echo "Installing HAL hooks to: $PROJECT_PATH"
echo "---"

# Install post-commit hook
POST_COMMIT_HOOK="$GIT_HOOKS_DIR/post-commit"

if [ -f "$POST_COMMIT_HOOK" ]; then
    echo "Warning: post-commit hook already exists"
    echo "Backing up to post-commit.bak"
    cp "$POST_COMMIT_HOOK" "$POST_COMMIT_HOOK.bak"
fi

# Create the post-commit hook
cat > "$POST_COMMIT_HOOK" << 'HOOK_CONTENT'
#!/bin/bash
# HAL post-commit hook
# Updates plan.md with commit hashes

# Find HAL scripts directory
HAL_SCRIPTS=""

# Check common locations
if [ -d "./hal/scripts" ]; then
    HAL_SCRIPTS="./hal/scripts"
elif [ -d "$HOME/.claude/hal/scripts" ]; then
    HAL_SCRIPTS="$HOME/.claude/hal/scripts"
fi

if [ -n "$HAL_SCRIPTS" ] && [ -f "$HAL_SCRIPTS/update-plan.sh" ]; then
    "$HAL_SCRIPTS/update-plan.sh" .
fi
HOOK_CONTENT

chmod +x "$POST_COMMIT_HOOK"
echo "Installed: post-commit hook"

# Copy the hooks to project's tars directory for portability
mkdir -p "$PROJECT_PATH/hal/hooks"
cp "$HOOKS_DIR/post-commit" "$PROJECT_PATH/hal/hooks/" 2>/dev/null || true

# Copy scripts as well
mkdir -p "$PROJECT_PATH/hal/scripts"
cp "$SCRIPT_DIR/update-plan.sh" "$PROJECT_PATH/hal/scripts/"
cp "$SCRIPT_DIR/parse-plan.sh" "$PROJECT_PATH/hal/scripts/"
chmod +x "$PROJECT_PATH/hal/scripts/"*.sh

echo "---"
echo "HAL hooks installed successfully!"
echo ""
echo "Hooks will:"
echo "  - Auto-log commit hashes to plan.md after each commit"
echo ""
echo "To uninstall:"
echo "  rm $POST_COMMIT_HOOK"
