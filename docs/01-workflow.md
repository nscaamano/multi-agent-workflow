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

### Watching workers run

Delegation doesn't mean flying blind. While workers run, you can observe their progress live —
take bounded snapshots of a worker's output, or follow its log in real time. The `watch-agents`
skill packages this (see [Installing the skills](../README.md#installing-the-skills)); invoke it
with `/watch-agents`.

---

## Parallel Writes and Git

Investigation parallelizes for free — it's read-only. Implementation does not. "Split into
N changes and delegate" sounds clean, but concurrent writes are where multi-agent workflows
actually get hard. The smoothness comes almost entirely from the **carve-up, before any agent
starts** — not from being clever about merging afterward.

### Decompose by ownership, not by task

The orchestrator's real job isn't "split the work" — it's split it so **no two agents write
the same file**. Good seams:

- **By directory/module** — agent A owns `app/picks/*`, agent B owns `lib/scoring.ts`.
- **By layer** — one agent does the data/types layer, another the UI that consumes it.
- **Vertical slices** — a whole feature end-to-end per agent, where features don't share files.

If you can decompose cleanly, the same-file problem mostly disappears. When you can't, that's a
signal the tasks aren't actually independent and probably shouldn't run in parallel.

> Treat "two agents want the same file" as a **decomposition smell** first. Only fall back to
> the owner/serialize/resolve tactics below when the split is genuinely unavoidable.

### Isolate with git worktrees

When agents must run truly concurrently, don't point them at the same working directory — they'd
clobber each other's uncommitted edits. Give each its own **git worktree**: a separate checkout
of the same repo on its own branch, sharing one `.git`. In Claude Code this is the Agent tool's
`isolation: "worktree"` flag (auto-cleaned if the agent makes no changes).

The flag gives you the *isolation*. The *integration loop* — merging N branches one at a time
and running the full build/tests at each merge — is something **you orchestrate**, not something
the flag does for you. Don't assume it's turnkey.

### Interface-first for anything shared

For work that shares a contract, define the shared surface first, in one place, sequentially —
the types, the function signatures, the API shape. Commit that, *then* fan out, so each agent
codes against a frozen interface and touches only its own implementation files. This is the
single highest-leverage move for parallel implementation.

Give it an escape hatch: an implementer will sometimes discover mid-task that the interface was
wrong. The rule is that they **escalate the change back to the orchestrator** rather than
silently editing the shared file — at which point you've hit a serialization point, and that's
fine.

### When they genuinely must touch the same file

In order of preference:

1. **Serialize it.** Keep the parallel agents off the file; make edits to it a sequential step
   the orchestrator (or one designated agent) does before or after the fan-out. Cheap and
   conflict-free.
2. **Designate an owner.** One agent owns the hot file; the others return a request ("I need this
   export added") and the owner applies it. Common for a types file, a router, or a barrel
   `index.ts`.
3. **Merge and resolve.** Let git merge, then fix conflicts as their own task — rebase branch B
   on the merged branch A and resolve (handing an agent both diffs as context if needed).

This is also where **lockfiles, DB migrations, and generated/barrel files** belong. They don't
map onto "agent A owns this directory," and they're the most common real-world collision —
almost always serialize them.

### The honest cost

- **A clean merge is not a correct merge.** Git auto-merges non-overlapping lines happily, and
  the build may even pass — but two agents can each add a different import, assume different
  state, or one can rename a symbol the other still calls. The dangerous conflicts are the
  *semantic* ones git never flags. Per-agent green does not guarantee integrated-green: run the
  full suite **at each integration**, not just inside each worktree.
- **Integration isn't free.** Merging branches, resolving conflicts, and re-running the suite is
  real orchestrator work. Past ~2–3 parallel writers it can exceed what you saved by going wide.
- **Conflicts cost more for agents than humans.** A human resolving a conflict has full context;
  an agent needs both diffs and the surrounding code re-loaded. The economics favor fewer,
  cleanly-separated writers over many overlapping ones.

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
   implement each piece in parallel. Decompose so no two agents write the same file — see
   [Parallel Writes and Git](#parallel-writes-and-git).
5. **Cross-model review.** After changes, have a second model review the diff against `main`
   and report back any issues. See [docs/03-cross-model-review.md](03-cross-model-review.md).
6. **Iterate on the hints file.** When something goes wrong, update the hints file so it
   doesn't happen again — then loop.

Copy-paste prompts for each step live in [docs/04-prompt-library.md](04-prompt-library.md).
