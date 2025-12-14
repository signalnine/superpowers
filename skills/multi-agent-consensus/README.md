# Multi-Agent Consensus Framework

Reusable infrastructure for multi-agent consensus. Any skill can invoke Claude, Gemini, and Codex to get diverse perspectives on prompts, designs, code, or decisions.

## Purpose

Different AI models have different strengths and weaknesses. Single agents may miss issues, exhibit biases, or have blind spots. This framework provides consensus from multiple agents, grouped by agreement level.

## Architecture

**Design:** `docs/plans/2025-12-13-multi-agent-consensus-framework-design.md`

**Key components:**
- Mode-based interface (code-review vs general-prompt)
- Shared consensus algorithm (word overlap + file matching)
- Three-tier output (High/Medium/Consider priority)
- Graceful degradation (works with 1, 2, or 3 reviewers)

## Usage

### Code Review Mode

```bash
skills/multi-agent-consensus/multi-consensus.sh --mode=code-review \
  --base-sha="abc123" \
  --head-sha="def456" \
  --plan-file="docs/plans/feature.md" \
  --description="Add authentication"
```

### General Prompt Mode

```bash
skills/multi-agent-consensus/multi-consensus.sh --mode=general-prompt \
  --prompt="What could go wrong with this design?" \
  --context="$(cat design.md)"
```

## Output Format

Three-tier consensus report:

```markdown
## High Priority - All Reviewers Agree
- [SEVERITY] description
  - Claude: "issue text"
  - Gemini: "issue text"
  - Codex: "issue text"

## Medium Priority - Majority Flagged (2/3)
- [SEVERITY] description
  - Claude: "issue text"
  - Gemini: "issue text"

## Consider - Single Reviewer Mentioned
- [SEVERITY] description
  - Codex: "issue text"
```

## Configuration

- `SIMILARITY_THRESHOLD=60` - Word overlap threshold for matching issues (default 60%)

## Dependencies

- Bash 4.0+
- git
- bc (for calculations)
- gemini CLI (optional, for Gemini reviews)
- Claude Code (optional, for Claude/Codex reviews)

## Integration Examples

**Brainstorming (design validation):**

```bash
DESIGN=$(cat docs/plans/2025-12-13-feature-design.md)

skills/multi-agent-consensus/multi-consensus.sh --mode=general-prompt \
  --prompt="Review this design for flaws, over-engineering, or missing requirements. Rate as STRONG/MODERATE/WEAK." \
  --context="$DESIGN"
```

**Systematic Debugging (root cause analysis):**

```bash
skills/multi-agent-consensus/multi-consensus.sh --mode=general-prompt \
  --prompt="What could cause this error? Analyze root causes." \
  --context="Error log: $ERROR_LOG"
```

## Testing

```bash
./skills/multi-agent-consensus/test-multi-consensus.sh
```

## Migration from multi-review.sh

Old code review calls:
```bash
skills/requesting-code-review/multi-review.sh "$BASE" "$HEAD" "$PLAN" "$DESC"
```

New code review calls:
```bash
skills/multi-agent-consensus/multi-consensus.sh --mode=code-review \
  --base-sha="$BASE" --head-sha="$HEAD" \
  --plan-file="$PLAN" --description="$DESC"
```
