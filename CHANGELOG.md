# Changelog

All notable changes to this workflow guide are recorded here. This is a living document —
log each meaningful iteration so the workflow's evolution is visible.

The format is loosely based on [Keep a Changelog](https://keepachangelog.com/).

## [0.1.0] — 2026-06-18

### Added

- Initial reference docs repo.
- `docs/01-workflow.md` — orchestrator + worker pattern, parallel subagents, parallel-writes
  and git (ownership-based decomposition, worktrees, interface-first, semantic-merge caveats),
  hints-file iteration, and the six-step replicate loop.
- `docs/02-ruleset.md` — merged behavioral ruleset (four principles adapted from the
  andrej-karpathy-skills guidelines, with orchestration-aware notes).
- `docs/03-cross-model-review.md` — tool-agnostic cross-model review.
- `docs/04-prompt-library.md` — copy-paste prompts per phase.
- `templates/CLAUDE.md` — drop-in hints file template.
- `.claude/skills/watch-agents/` — skill to observe spawned worker agents live (list running
  agents, snapshot their latest output, or hand off a live `tail -f`), with an `agent-watch.sh`
  helper.
- `install.sh` — copies bundled skills to `~/.claude/skills/` (global) or a target project's
  `.claude/skills/`; re-run to update. Documented in the README.
- `.gitignore` — ignores `.agent-logs/` and `*.log` (captured worker-agent output).
- `README.md`, `ATTRIBUTION.md`, `LICENSE`.
