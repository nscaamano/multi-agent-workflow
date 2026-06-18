# The Multi-Agent Coding Workflow

A reference guide for orchestrator-based AI coding workflows using Claude Code (or any
agentic CLI) and cross-model review.

---

## The Core Concept: Orchestrator + Worker

The main AI session shouldn't do the work itself — it should act like a project manager
that delegates to specialized workers (subagents).

Every time you talk to an LLM, the entire conversation history gets re-sent to the model on
each turn. So if one agent investigates the codebase, plans the work, writes the code, and
reviews it all in a single session, that context balloons fast — and you're paying (in tokens
*and* in quality) to re-process all of it every turn. Splitting work across focused subagents
keeps each one's context lean and on-task.

The orchestrator's job is to **decompose, delegate, and integrate** — not to hold every detail
in its own context window.

---

## Orchestration with Parallel Subagents

Use the main session to spawn several subagents simultaneously to investigate different aspects
of a problem in parallel. Then, when it's time to actually write code, the main agent splits the
implementation work and delegates pieces to fresh subagents.

**Benefits:**

- **Faster** — parallel work instead of sequential.
- **Higher quality** — each subagent is focused on one specific thing rather than juggling
  everything at once.
- **Lower token usage** — counterintuitive but true: each subagent has a small, focused context
  window instead of one giant ballooning one.

### Two places to parallelize

1. **Investigation fan-out.** Before planning a change, spawn multiple read-only subagents to
   map the problem — one traces the data flow, one checks related tests, one looks for similar
   patterns elsewhere. They report back; *then* you plan.
2. **Implementation split.** Once you have a plan, break it into independent changes and hand
   each to its own subagent. Independence is the key constraint — pieces that don't touch the
   same files can be built in parallel without conflicts.

> Rule of thumb: if two subtasks would edit the same file or depend on each other's output,
> they are not independent — sequence them or give them to one agent.

---

## Iterating on the Hints File

Keep a `CLAUDE.md` (or `AGENTS.md`) file in your repo root. This is where you give the agent
persistent instructions, conventions, and gotchas.

Every time the agent makes a mistake — or you find yourself correcting it — add a note to that
file so it doesn't repeat the mistake. The fix for "the agent did X wrong" isn't just "do it
right this time"; it's **"update the hints file so this doesn't happen again."** Over time, the
workflow gets noticeably better.

Start small: your tech stack, code style preferences, and any gotchas. Grow it whenever the
agent does something dumb. See [templates/CLAUDE.md](../templates/CLAUDE.md) for a starting
point and [docs/02-ruleset.md](02-ruleset.md) for the behavioral rules it encodes.

---

## How the Mechanics Actually Work

The main agent can run shell commands. So you can literally prompt it to drive other tools —
including other AI CLIs — as ordinary bash commands:

```text
"Start a terminal and run <other CLI> to launch it, then prompt it to review your changes."
```

As long as the other CLI is installed on your machine, the main agent treats it like any other
bash command. This is what makes cross-model review (below) possible without any special
integration.

---

## The Replicate Loop

A six-step loop you can run on any project:

1. **Install the CLIs.** At minimum, your primary agentic CLI (e.g. Claude Code). Optionally add
   a second CLI (Codex, Gemini, or any other) for cross-model review.
2. **Create a hints file.** Place `CLAUDE.md` / `AGENTS.md` in the repo root. Start small —
   stack, style, gotchas. Add to it whenever the agent slips.
3. **Orchestrate investigation.** Instead of "fix this bug," fan out: spawn subagents to trace
   the data flow, check related tests, and find similar patterns. Report back, then plan.
4. **Delegate implementation.** Split the plan into independent changes and have subagents
   implement each piece in parallel.
5. **Cross-model review.** After changes, have a second model review the diff against `main`
   and report back any issues. See [docs/03-cross-model-review.md](03-cross-model-review.md).
6. **Iterate on the hints file.** When something goes wrong, update the hints file so it
   doesn't happen again — then loop.

Copy-paste prompts for each step live in [docs/04-prompt-library.md](04-prompt-library.md).
