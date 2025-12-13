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

echo "Multi-review placeholder - BASE: $BASE_SHA, HEAD: $HEAD_SHA"
exit 0
