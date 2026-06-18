# Cross-Model Review

After your primary agent makes changes, have a **different** model review the diff. It's code
review, but the reviewer is another AI.

## Why it works

Different models have different blind spots and different strengths. One model catches things
another misses — a bug the author's model glossed over, an edge case it didn't consider, a
convention it broke. Using a second model as the reviewer is the cheapest way to get a genuinely
independent second opinion on a diff.

This is deliberately **tool-agnostic**. The reviewer can be any agentic CLI you have installed —
Codex, Gemini, or anything else. What matters is that it's a *different* model from the one that
wrote the code.

## How it works mechanically

Your primary agent can run shell commands, so it can launch the reviewer CLI as an ordinary
bash command, point it at the diff, and read back what it says. No special integration is
needed — if the second CLI is installed, the orchestrator treats it like any other command.

The flow:

1. Primary agent makes changes on a branch.
2. Orchestrator shells out to the second CLI and asks it to review the diff against `main`.
3. Reviewer reports issues; orchestrator triages them and addresses the real ones.

## Review prompt template

```text
"Now run <other CLI> in a terminal and have it review the diff against main.
 Report back any issues it raises."
```

A more directed version:

```text
"Launch <other CLI> and have it review the diff against main. Ask it specifically to check
 for: (1) logic errors and edge cases, (2) anything that breaks existing behavior,
 (3) deviations from the conventions in CLAUDE.md. Summarize its findings and tell me which
 are worth acting on."
```

## Triage, don't auto-apply

Treat the reviewer's output as findings to evaluate, not orders to follow. A second model will
sometimes flag style preferences or "issues" that don't apply to your codebase. The orchestrator
should decide which findings are real — and, where useful, fold recurring valid feedback back
into the [hints file](01-workflow.md#iterating-on-the-hints-file) so the first model stops making
that mistake.

## When to use it

- **Always worth it** for non-trivial diffs, anything touching shared/critical paths, or changes
  produced by parallel subagents (where no single agent saw the whole picture).
- **Optional** for tiny, obviously-correct changes — apply judgment proportional to risk.
