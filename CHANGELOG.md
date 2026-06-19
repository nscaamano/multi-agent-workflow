# Changelog

All notable changes to this workflow guide are recorded here. This is a living document —
log each meaningful iteration so the workflow's evolution is visible.

The format is loosely based on [Keep a Changelog](https://keepachangelog.com/).

## [0.1.0] — 2026-06-18

### Added

- Initial reference docs repo.
- `docs/01-workflow.md` — orchestrator + worker pattern, parallel subagents, matching the model
  tier to the job (orchestrate on Opus, implement on Sonnet, recon on Haiku; cold-start vs.
  fork), parallel-writes and git (ownership-based decomposition, worktrees, interface-first,
  semantic-merge caveats), hints-file iteration, and the six-step replicate loop.
- `docs/02-ruleset.md` — merged behavioral ruleset (four principles adapted from the
  andrej-karpathy-skills guidelines, with orchestration-aware notes).
- `docs/03-cross-model-review.md` — tool-agnostic cross-model review, including how provider
  selection actually happens (no automatic router; you/the hints file decide, native subagent
  vs. shell-out, independence and billing as the two reasons to cross providers).
- `docs/04-prompt-library.md` — copy-paste prompts per phase.
- `templates/CLAUDE.md` — drop-in hints file template.
- `.claude/skills/watch-agents/` — skill to observe spawned worker agents live (list running
  agents, snapshot their latest output, or hand off a live `tail -f`), with an `agent-watch.sh`
  helper.
- `.claude/agents/implementer.md` — worker agent pinned to Sonnet for scoped implementation
  fan-out, keeping the strong model for orchestration.
- `install.sh` — copies bundled skills and agents to `~/.claude/` (global) or a target project's
  `.claude/`; re-run to update. Documented in the README.
- `setup.sh` — interactive wizard (bash terminal menus) that generates a project `CLAUDE.md`:
  asks which provider/model handles each task type (orchestration, implementation, recon,
  review) plus stack basics, single-sources the behavioral rules from the template, and backs
  up any existing file before overwrite. When the project deploys to Vercel, it also captures
  the expected git commit author and writes a gotcha to confirm `git config user.name`/`user.email`
  match it before committing (a mismatched author after switching machines has blocked deploys).
- `.gitignore` — ignores `.agent-logs/` and `*.log` (captured worker-agent output).
- `README.md`, `ATTRIBUTION.md`, `LICENSE`.
