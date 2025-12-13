#!/usr/bin/env bash
set -e

echo "Testing multi-review.sh..."

# Test: Missing arguments
if ./skills/requesting-code-review/multi-review.sh 2>&1 | grep -q "Usage:"; then
    echo "✓ Shows usage when no arguments"
else
    echo "✗ Should show usage when no arguments"
    exit 1
fi

echo "All tests passed!"
