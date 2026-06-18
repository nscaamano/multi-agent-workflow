# Multi-Agent Coding Workflow

A reference guide for orchestrator-based AI coding workflows using Claude Code and cross-model review.

---

## The Core Concept: Orchestrator + Worker Pattern

The main AI session shouldn't do the work itself—it should act like a project manager that delegates to specialized workers (subagents).

Every time you talk to an LLM, the entire conversation history gets re-sent to the model on each turn. So if one agent investigates the codebase, plans the work, writes the code, and reviews it all in one session, that context balloons fast and you're paying (in tokens and quality) to re-process all of it every turn. Splitting work across focused subagents keeps each one's context lean and on-task.

---

## Orchestration with Parallel Subagents

Use the main session in Claude Code (CC) to spawn 5+ subagents simultaneously to investigate different aspects of a problem in parallel. Then when it's time to actually write code, the main agent splits the implementation work and delegates pieces to fresh subagents.

**Benefits:**

- **Faster** — parallel work instead of sequential.
- **Higher quality** — each subagent is focused on one specific thing rather than juggling everything.
- **Lower token usage** — counterintuitive but true, because each subagent has a small focused context window instead of one giant ballooning one.

---

## Iterating on the Hints File

Keep a **CLAUDE.md** (or **AGENTS.md**) file in your repo root. This is where you give the agent persistent instructions, conventions, and gotchas. Every time the agent makes a mistake or you find yourself correcting it, add a note to that file so it doesn't repeat the mistake. Over time, the workflow gets noticeably better.

---

## Cross-Model Review

After Claude Code makes changes, spawn a Codex CLI process (OpenAI's coding CLI) to review the diff. Different models have different blind spots and strengths, so one model catches things the other misses. It's code review, but the reviewer is a different AI.

---

## How the Mechanics Actually Work

The main agent (Claude Code) can run shell commands. So you literally just prompt it with something like:

```
"Start a terminal and run codex (or claude) to launch the CLI, then prompt it to review your changes."
```

As long as the other CLI is installed on your machine, the main agent treats it like any other bash command.

---

## How to Replicate This Workflow

### 1. Install the CLIs

At minimum: Claude Code. Optionally add Codex CLI (OpenAI), Gemini CLI, or whatever else you want for cross-review.

### 2. Create a CLAUDE.md (or AGENTS.md)

Place it in your repo root. Start small — your tech stack, code style preferences, any gotchas. Add to it whenever the agent does something dumb.

### 3. Practice the Orchestrator Pattern

Instead of saying "fix this bug," try:

```
"Spawn 3 subagents to investigate: one to trace the data flow, one to check related test files, one to look for similar patterns elsewhere in the codebase. Report back and then we'll plan the fix."
```

Claude Code's Task tool handles this.

### 4. Delegate Implementation Too

```
"Split this into 4 independent changes and have subagents implement each one in parallel."
```

### 5. Cross-Model Review

After changes:

```
"Now run codex in a terminal and have it review the diff against main. Report back any issues it raises."
```

### 6. Iterate on the Hints File

When something goes wrong, the fix isn't just "do it right this time" — it's "update CLAUDE.md so this doesn't happen again."

---

## Quick Reference

- **Main session = orchestrator only.** Delegate all real work.
- **Parallelize investigation.** 5+ subagents > 1 mega-agent.
- **Parallelize implementation.** Split changes, delegate pieces.
- **Cross-model review.** Have Codex review Claude's work (or vice versa).
- **Keep a hints file.** Update CLAUDE.md/AGENTS.md whenever the agent misses something.
- **Less context = better outputs.** Focused subagents beat one giant context window.
