#!/usr/bin/env bash
set -euo pipefail

# Multi-reviewer code review script
# Coordinates parallel reviews from Claude, Gemini, and Codex

show_usage() {
    cat <<EOF
Usage: $0 <BASE_SHA> <HEAD_SHA> <PLAN_FILE> <DESCRIPTION>

Arguments:
  BASE_SHA     - Starting commit for review
  HEAD_SHA     - Ending commit for review
  PLAN_FILE    - Path to plan/requirements document (or "-" for none)
  DESCRIPTION  - Brief description of what was implemented

Example:
  $0 abc123 def456 docs/plans/feature.md "Add user authentication"
EOF
}

# Validate arguments
if [ $# -lt 4 ]; then
    show_usage
    exit 1
fi

BASE_SHA="$1"
HEAD_SHA="$2"
PLAN_FILE="$3"
DESCRIPTION="$4"

# Check for --dry-run flag (for testing)
DRY_RUN=false
if [ "${5:-}" = "--dry-run" ]; then
    DRY_RUN=true
fi

# === Context Preparation ===

# Validate git SHAs exist
if ! git rev-parse "$BASE_SHA" >/dev/null 2>&1; then
    echo "Error: BASE_SHA '$BASE_SHA' not found in repository" >&2
    exit 1
fi

if ! git rev-parse "$HEAD_SHA" >/dev/null 2>&1; then
    echo "Error: HEAD_SHA '$HEAD_SHA' not found in repository" >&2
    exit 1
fi

# Validate SHAs are different
if [ "$(git rev-parse "$BASE_SHA")" = "$(git rev-parse "$HEAD_SHA")" ]; then
    echo "Warning: BASE_SHA and HEAD_SHA point to the same commit - no changes to review" >&2
fi

# Get git diff
GIT_DIFF=$(git diff "$BASE_SHA..$HEAD_SHA")

# Get modified files
MODIFIED_FILES=$(git diff --name-only "$BASE_SHA..$HEAD_SHA")
if [ -z "$MODIFIED_FILES" ]; then
    MODIFIED_FILES_COUNT=0
else
    MODIFIED_FILES_COUNT=$(echo "$MODIFIED_FILES" | wc -l | tr -d ' ')
fi

# Read plan file if provided
PLAN_CONTENT=""
if [ "$PLAN_FILE" != "-" ]; then
    if [ -f "$PLAN_FILE" ]; then
        PLAN_CONTENT=$(cat "$PLAN_FILE")
    else
        echo "Warning: Plan file '$PLAN_FILE' not found" >&2
    fi
fi

# Build full context
FULL_CONTEXT="# Code Review Context

**Description:** $DESCRIPTION
**Commits:** $BASE_SHA..$HEAD_SHA
**Modified files:** $MODIFIED_FILES_COUNT

## Modified Files
$MODIFIED_FILES

## Git Diff
\`\`\`diff
$GIT_DIFF
\`\`\`

## Plan/Requirements
$PLAN_CONTENT
"

if [ "$DRY_RUN" = true ]; then
    echo "Modified files: $MODIFIED_FILES_COUNT"
    exit 0
fi

echo "Context prepared: $MODIFIED_FILES_COUNT file(s) modified"
