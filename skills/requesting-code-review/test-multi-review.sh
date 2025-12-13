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

# Test: Context preparation
# Create a test repo with commits
test_dir=$(mktemp -d)
cd "$test_dir"
git init -q
echo "line1" > file.txt
git add file.txt
git commit -q -m "first commit"
FIRST_SHA=$(git rev-parse HEAD)
echo "line2" >> file.txt
git commit -q -am "second commit"
SECOND_SHA=$(git rev-parse HEAD)

# Run script in dry-run mode (add --dry-run flag)
if $OLDPWD/skills/requesting-code-review/multi-review.sh \
    "$FIRST_SHA" "$SECOND_SHA" "-" "test change" --dry-run 2>&1 \
    | grep -q "Modified files: 1"; then
    echo "✓ Extracts git context correctly"
else
    echo "✗ Should extract git context"
    exit 1
fi

cd "$OLDPWD"
rm -rf "$test_dir"

echo "All tests passed!"
