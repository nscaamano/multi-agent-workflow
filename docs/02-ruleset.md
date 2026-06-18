# The Behavioral Ruleset

The [workflow](01-workflow.md) describes *how to orchestrate*. This ruleset describes *how the
worker should behave* once it's doing the work. It applies equally to the orchestrator and to
every subagent it spawns.

These four principles are adapted from the
[andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) guidelines
(MIT) and merged here with orchestration-aware notes for this workflow. See
[ATTRIBUTION.md](../ATTRIBUTION.md).

Apply judgment proportional to the task: a one-line fix doesn't need a written plan; a
multi-file change does. The goal is to trade a little speed for far fewer wasted rewrites.

---

## 1. Think Before Coding

**State your assumptions explicitly. If uncertain, ask.**

Don't assume, and don't hide confusion. When a request has more than one reasonable
interpretation, name them rather than silently picking one. Surface tradeoffs before you act,
and stop to ask a clarifying question when the answer would change what you build.

*In this workflow:* the orchestrator should resolve ambiguity **before** fanning out work —
a wrong assumption multiplied across five parallel subagents is five times the cleanup. Put
the agreed interpretation into the prompts you hand to subagents.

---

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

Write the least code that solves the actual problem. No unrequested features, no single-use
abstractions, no error handling for scenarios that can't occur. The test: would a senior
engineer call it overcomplicated? If so, cut it back.

*In this workflow:* scope each subagent to exactly its slice. A subagent told to "add a config
flag" should add the flag — not refactor the config system because it could be cleaner.

---

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code, match the surrounding style and avoid improving unrelated code.
Remove only the imports or functions that *your* change made orphaned — don't delete
pre-existing dead code unless explicitly asked.

*In this workflow:* surgical changes are what make parallel implementation safe. The smaller
and more contained each subagent's diff is, the less it overlaps with the others — split work
along boundaries that keep each diff narrow and independent.

---

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Turn the task into a measurable goal with a concrete verification step, then iterate until that
step passes. For multi-step work, outline a brief plan showing each step and how you'll verify
it. LLMs are exceptionally good at looping until they meet a specific goal — so give success
criteria, not a rigid list of instructions.

*In this workflow:* delegate by **success criteria, not step-by-step orders**. Tell a subagent
"the new endpoint returns 200 with the user's profile and the existing tests still pass," and
let it find the path there. Then verify its result — ideally with a
[cross-model review](03-cross-model-review.md).

---

## How you know it's working

These rules are doing their job when:

- Diffs get smaller and contain only changes relevant to the task.
- Rewrites caused by overcomplication go away.
- Clarifying questions move to *before* implementation instead of after a wrong guess.
- Parallel subagents finish without stepping on each other's files.
