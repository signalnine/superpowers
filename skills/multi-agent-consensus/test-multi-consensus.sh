#!/usr/bin/env bash
set -e

SCRIPT="$(dirname "$0")/multi-consensus.sh"

echo "Testing multi-consensus.sh..."

# Test: Missing --mode flag
if $SCRIPT 2>&1 | grep -q "Error.*--mode"; then
    echo "✓ Requires --mode flag"
else
    echo "✗ Should require --mode flag"
    exit 1
fi

# Test: Invalid mode value
if $SCRIPT --mode=invalid 2>&1 | grep -q "Error.*Invalid mode"; then
    echo "✓ Rejects invalid mode"
else
    echo "✗ Should reject invalid mode"
    exit 1
fi

# Test: Valid mode without required args
if $SCRIPT --mode=code-review 2>&1 | grep -q "Error.*base-sha"; then
    echo "✓ Code review mode requires --base-sha"
else
    echo "✗ Code review mode should require --base-sha"
    exit 1
fi

if $SCRIPT --mode=general-prompt 2>&1 | grep -q "Error.*prompt"; then
    echo "✓ General prompt mode requires --prompt"
else
    echo "✗ General prompt mode should require --prompt"
    exit 1
fi

echo "All tests passed!"
