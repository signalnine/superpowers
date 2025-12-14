# Multi-Agent Consensus Framework

Reusable infrastructure for multi-agent consensus. Any skill can invoke Claude, Gemini, and Codex to get diverse perspectives on prompts, designs, code, or decisions.

## Architecture

See: `docs/plans/2025-12-13-multi-agent-consensus-framework-design.md`

## Usage

From any skill:

```bash
../multi-agent-consensus/multi-consensus.sh --mode=general-prompt \
  --prompt="What could go wrong?" \
  --context="$BACKGROUND"
```

Output: Markdown consensus report grouped by agreement level.
