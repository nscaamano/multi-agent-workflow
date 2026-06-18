# Multi-Agent Coding Workflow

A reference guide for orchestrator-based AI coding workflows using Claude Code (or any
agentic CLI), parallel subagents, an iterated hints file, and cross-model review.

The core idea: **the main AI session shouldn't do the work itself — it should act like a
project manager that delegates to focused subagents.** Splitting work across focused workers
keeps each one's context lean and on-task, which is faster, higher quality, *and* cheaper.

## Quick Reference

- **Main session = orchestrator only.** Delegate all real work.
- **Parallelize investigation.** 5+ focused subagents beat one mega-agent.
- **Parallelize implementation.** Split changes into independent pieces, delegate each.
- **Cross-model review.** Have a second model review the first model's work.
- **Keep a hints file.** Update `CLAUDE.md` / `AGENTS.md` whenever the agent misses something.
- **Less context = better outputs.** Focused subagents beat one giant context window.

## Contents

- [docs/01-workflow.md](docs/01-workflow.md) — the core workflow: orchestrator + worker,
  parallel subagents, iterating on the hints file, and the full replicate loop.
- [docs/02-ruleset.md](docs/02-ruleset.md) — the merged behavioral ruleset (how the worker
  should behave): Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution.
- [docs/03-cross-model-review.md](docs/03-cross-model-review.md) — why and how to have a
  second model review the work, written tool-agnostically.
- [docs/04-prompt-library.md](docs/04-prompt-library.md) — copy-paste prompts for each phase.
- [templates/CLAUDE.md](templates/CLAUDE.md) — a drop-in hints file for your own projects.

## How to use this repo

1. Read [docs/01-workflow.md](docs/01-workflow.md) to understand the orchestrator pattern.
2. Copy [templates/CLAUDE.md](templates/CLAUDE.md) into the root of your own project and
   fill in the placeholders (tech stack, conventions, gotchas).
3. Drive your agentic CLI using the prompts in
   [docs/04-prompt-library.md](docs/04-prompt-library.md).
4. **Iterate.** Every time the agent makes a mistake, add a line to your project's hints
   file — and improve this repo's docs as your workflow sharpens.

See [ATTRIBUTION.md](ATTRIBUTION.md) for sources and [CHANGELOG.md](CHANGELOG.md) for the
revision history. Licensed under [MIT](LICENSE).
