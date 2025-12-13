---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements - dispatches multiple AI reviewers (Claude, Gemini, Codex) in parallel for thorough consensus-based code review
---

# Requesting Code Review

Get parallel reviews from Claude, Gemini, and Codex to catch issues before they cascade.

**Core principle:** Multiple independent reviews = maximum coverage.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspectives)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request Multi-Reviewer Consensus

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Identify plan file:**
```bash
PLAN_FILE="docs/plans/2025-12-13-feature-name.md"  # or "-" if no plan
DESCRIPTION="Brief description of what was implemented"
```

**3. Launch parallel reviews:**

You must coordinate three reviewers simultaneously:

**a) Invoke Gemini via script (captures output):**
```bash
GEMINI_OUTPUT=$(./skills/requesting-code-review/multi-review.sh \
    "$BASE_SHA" "$HEAD_SHA" "$PLAN_FILE" "$DESCRIPTION" 2>/dev/null) &
GEMINI_PID=$!
```

**b) Dispatch Claude subagent (via Task tool):**

Use Task tool with superpowers:code-reviewer type, filling these placeholders:
- WHAT_WAS_IMPLEMENTED: $DESCRIPTION
- PLAN_OR_REQUIREMENTS: Content from $PLAN_FILE
- BASE_SHA: $BASE_SHA
- HEAD_SHA: $HEAD_SHA
- DESCRIPTION: $DESCRIPTION

**c) Invoke Codex MCP:**

Use `mcp__codex-cli__codex` tool with prompt:
```
You are a senior code reviewer. Review this code change:

[Include git diff from $BASE_SHA to $HEAD_SHA]
[Include plan/requirements from $PLAN_FILE]
[Include description: $DESCRIPTION]

Provide structured feedback:

## Critical Issues
- [issues or 'None']

## Important Issues
- [issues or 'None']

## Suggestions
- [suggestions or 'None']
```

**4. Wait for all reviews to complete:**

```bash
# Wait for Gemini
wait $GEMINI_PID
GEMINI_REVIEW="$GEMINI_OUTPUT"

# Claude and Codex complete when their tools return
CLAUDE_REVIEW="[from Task tool result]"
CODEX_REVIEW="[from MCP tool result]"
```

**5. Aggregate into consensus report (manual aggregation by assistant):**

Parse each review for issues and group by consensus level:
- **All reviewers agree** (3/3 or 2/2 if one failed) → HIGH PRIORITY
- **Majority flagged** (2/3) → MEDIUM PRIORITY
- **Single reviewer** (1/3) → CONSIDER

Use issue similarity matching: issues are similar if they reference the same file AND have 60% word overlap in description.

**Note:** The multi-review.sh script automatically handles consensus aggregation for Gemini's output. For Claude and Codex reviews, the assistant must manually identify similar issues across all three reviewers and group them appropriately.

**6. Act on consensus feedback:**
- **All reviewers agree** → Fix immediately before proceeding
- **Majority flagged** → Fix unless you have strong reasoning otherwise
- **Single reviewer** → Consider, but use judgment
- Push back if feedback is wrong (with technical reasoning)

## Simplified Single-Reviewer Mode

If you need a quick review, use Claude-only mode:

Dispatch `superpowers:code-reviewer` subagent directly with Task tool.

This skips Gemini/Codex and gives you just Claude's review.

## Example Multi-Review Workflow

```
[Just completed Task 2: Add verification function]

You: Let me request consensus code review.

# Get SHAs
BASE_SHA=a7981ec
HEAD_SHA=3df7661
PLAN_FILE="docs/plans/deployment-plan.md"
DESCRIPTION="Added verifyIndex() and repairIndex() with 4 issue types"

# Launch Gemini
[Invoke multi-review.sh script in background]

# Launch Claude subagent
[Dispatch superpowers:code-reviewer with Task tool]

# Launch Codex MCP
[Use mcp__codex-cli__codex tool]

# Wait for all three

# Aggregate results:
## High Priority - All Reviewers Agree
- [Critical] Missing progress indicators
  - Claude: "No user feedback during long operations"
  - Gemini: "Progress reporting missing for iteration"
  - Codex: "Add progress callbacks"

## Medium Priority - Majority Flagged (2/3)
- [Important] Magic number in code
  - Claude: "100 should be a named constant"
  - Codex: "Extract BATCH_SIZE constant"

## Summary
- Critical: 1 (consensus: 1)
- Important: 1 (consensus: 0, majority: 1)

You: [Fix progress indicators immediately]
You: [Fix magic number]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- All three reviewers for thoroughness
- Fix consensus issues before next task

**Executing Plans:**
- Review after each batch (3 tasks)
- Get consensus feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues from consensus
- Proceed with unfixed consensus issues
- Argue with valid technical feedback from multiple reviewers

**If reviewers wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

**If reviewers disagree:**
- Consensus issues (all agree) take priority
- Investigate majority-flagged issues
- Use judgment on single-reviewer issues

## Troubleshooting

**Gemini not available:**
- Script will mark Gemini as "✗ (not available)"
- Continue with Claude + Codex
- Consensus threshold adjusts (2/2 instead of 3/3)

**Codex MCP fails:**
- Mark Codex as "✗ (error)"
- Continue with Claude + Gemini
- Consensus threshold adjusts

**Only Claude succeeds:**
- Falls back to single-reviewer mode
- Still get thorough review from Claude
- Consider why other reviewers failed

## Files

- `multi-review.sh` - Gemini coordination script
- `code-reviewer.md` - Claude agent definition (used by Task tool)
- `README.md` - Architecture documentation
