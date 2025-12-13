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

# === Reviewer Functions ===

# Launch Claude code-reviewer subagent
# NOTE: This is a placeholder - actual implementation requires Claude Code Task tool
launch_claude_review() {
    local context="$1"

    # For now, return mock review
    cat <<EOF
# Claude Code Review

## Critical Issues
- Missing error handling in main function

## Important Issues
- No input validation

## Suggestions
- Consider adding logging
EOF
}

# Launch Gemini CLI review
launch_gemini_review() {
    local context="$1"

    # Check if gemini CLI is available
    if ! command -v gemini &> /dev/null; then
        echo "GEMINI_NOT_AVAILABLE"
        return 1
    fi

    # For now, return mock review
    cat <<EOF
# Gemini Code Review

## Critical Issues
- Missing error handling in main function

## Important Issues
- Edge case not handled

## Suggestions
- Add unit tests
EOF
}

# Launch Codex MCP review
# NOTE: This is a placeholder - actual implementation requires MCP tool
launch_codex_review() {
    local context="$1"

    # For now, return mock review
    cat <<EOF
# Codex Code Review

## Important Issues
- No input validation
- Edge case not handled

## Suggestions
- Improve naming
EOF
}

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

# === Parallel Review Execution ===

echo "Launching reviewers..." >&2

# Launch Claude review (required, blocking)
echo "  - Claude (required)..." >&2
CLAUDE_REVIEW=$(launch_claude_review "$FULL_CONTEXT" 2>&1)
CLAUDE_EXIT=$?

if [ $CLAUDE_EXIT -ne 0 ]; then
    echo "Error: Claude review failed" >&2
    exit 1
fi

# Launch Gemini review (optional, synchronous for now)
# TODO Task 6: Convert to parallel background with timeout when integrating real Gemini CLI
echo "  - Gemini (optional)..." >&2
GEMINI_REVIEW=$(launch_gemini_review "$FULL_CONTEXT" 2>&1)
GEMINI_EXIT=$?

# Launch Codex review (optional, synchronous for now)
# TODO Task 6+: Convert to parallel background with timeout when integrating real Codex MCP
echo "  - Codex (optional)..." >&2
CODEX_REVIEW=$(launch_codex_review "$FULL_CONTEXT" 2>&1)
CODEX_EXIT=$?

# Determine which reviewers succeeded
CLAUDE_STATUS="✓"  # Always succeeds (script exits on Claude failure)
GEMINI_STATUS="✗ (not available)"
CODEX_STATUS="✗ (not available)"

if [ $GEMINI_EXIT -eq 0 ] && ! echo "$GEMINI_REVIEW" | grep -q "GEMINI_NOT_AVAILABLE"; then
    GEMINI_STATUS="✓"
fi

if [ $CODEX_EXIT -eq 0 ]; then
    CODEX_STATUS="✓"
fi

echo "Reviewers complete:" >&2
echo "  - Claude: $CLAUDE_STATUS" >&2
echo "  - Gemini: $GEMINI_STATUS" >&2
echo "  - Codex: $CODEX_STATUS" >&2

# For now, just output raw reviews
echo "# Multi-Reviewer Code Review Report"
echo ""
echo "**Reviewers**: Claude $CLAUDE_STATUS, Gemini $GEMINI_STATUS, Codex $CODEX_STATUS"
echo ""
echo "## Claude Review"
echo "$CLAUDE_REVIEW"
echo ""
echo "## Gemini Review"
echo "$GEMINI_REVIEW"
echo ""
echo "## Codex Review"
echo "$CODEX_REVIEW"

exit 0
