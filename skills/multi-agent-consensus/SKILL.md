---
name: multi-agent-consensus
description: Reusable multi-agent consensus infrastructure for any skill needing diverse AI perspectives (Claude/Gemini/Codex)
---

# Multi-Agent Consensus

## Overview

Provides reusable infrastructure for getting consensus from Claude, Gemini, and Codex on any prompt or task. Groups responses by agreement level (all agree, majority, single reviewer).

## When to Use

Use when you need diverse AI perspectives to reduce bias and blind spots:
- Design validation (brainstorming)
- Code review (requesting-code-review)
- Root cause analysis (debugging)
- Verification checks (before completion)

## Interface

**Code review mode:**
```bash
multi-consensus.sh --mode=code-review \
  --base-sha="$BASE" --head-sha="$HEAD" \
  --plan-file="$PLAN" --description="$DESC"
```

**General prompt mode:**
```bash
multi-consensus.sh --mode=general-prompt \
  --prompt="Your question here" \
  --context="Optional background info"
```

## Output

Three-tier consensus report:
- **High Priority** - All reviewers agree
- **Medium Priority** - Majority (2/3) flagged
- **Consider** - Single reviewer mentioned

## Configuration

- `SIMILARITY_THRESHOLD=60` - Word overlap threshold for issue matching (default 60%)
