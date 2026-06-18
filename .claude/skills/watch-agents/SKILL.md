---
name: watch-agents
description: Observe what spawned worker agents (Codex, Gemini, or Claude Code background tasks) are doing — list running agents, snapshot their latest output, or set up a live follow. Use when the user asks to see, watch, monitor, tail, or check on a background/spawned/worker agent or its log.
---

# Watching spawned agents live

Workers launched by the orchestrator (a `codex exec`, a background `claude`, etc.) write their
progress to a log. This skill locates those logs and shows their activity. There are two cases:

1. **Self-launched CLI agents** — you (or the orchestrator) started a CLI and redirected its
   output to a file. By convention in this repo that file lives in `.agent-logs/` (gitignored).
2. **Claude Code background tasks** — when the orchestrator runs a Bash command with
   `run_in_background: true`, the harness streams its output to a task file and tracks it.

## The one hard constraint

**Never run `tail -f` (or any unbounded follow) yourself** — it never returns and hangs the
session. When *you* (Claude) are checking on an agent, take a **bounded snapshot**. Only a true
live follow goes to the user, who runs it in their own terminal.

## How to watch

### Step 1 — find the running agents and their logs

```bash
.claude/skills/watch-agents/agent-watch.sh list
```

This prints any running `codex`/`gemini`/`claude` worker processes and the newest log files in
`.agent-logs/`, plus a best-effort scan of Claude Code background-task output files.

### Step 2 — snapshot the latest output (for Claude to read)

```bash
.claude/skills/watch-agents/agent-watch.sh tail            # newest log in .agent-logs/
.claude/skills/watch-agents/agent-watch.sh tail <path> 80  # a specific file, last 80 lines
```

Repeat the snapshot to see new progress. Do **not** convert this into a follow loop that blocks;
if the user wants continuous polling, use the `Monitor` tool (it polls a background task until a
condition) rather than a foreground loop.

### Step 3 — hand the user a live follow (optional)

If the user wants to watch it stream in real time, give them this to run in their **own**
terminal (the leading `!` runs it in the user's shell from the Claude Code prompt; `Ctrl-C` stops
the tail and does not touch the agent):

```text
! tail -f .agent-logs/<file>.log
```

For Claude Code background tasks whose path line-wraps, a glob avoids retyping long segments:

```text
! tail -f /tmp/claude-*/*/*/tasks/<id>.output
```

## Launching an agent so it's watchable

If you're starting a worker yourself, log it into `.agent-logs/` so this skill can find it:

```bash
mkdir -p .agent-logs
codex exec -s workspace-write "your prompt" > .agent-logs/codex-$(date +%s).log 2>&1 &
```

`> file 2>&1` captures stdout+stderr; `&` backgrounds it. `.agent-logs/` is gitignored.

## Notes

- **Snapshot, don't follow, when reading as Claude.** `tail -n 50` shows recent activity and
  returns; an unbounded `tail -f` becomes a stray "active shell" that lingers.
- **Codex keeps its own session log** under `~/.codex/sessions/YYYY/MM/DD/*.jsonl`, and
  `codex resume --last` reopens the most recent run interactively — useful if no log was captured.
- Harness background-task paths (`/tmp/claude-*/.../tasks/*.output`) are internal and can change
  between versions; prefer the `.agent-logs/` convention for anything you launch yourself.
