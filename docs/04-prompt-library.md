# Prompt Library

Copy-paste prompts for driving the orchestrator through each phase of the
[workflow](01-workflow.md). Adapt the specifics; keep the shape.

---

## Investigation fan-out

Instead of "fix this bug," spawn focused read-only subagents to map the problem first:

```text
"Spawn 3 subagents to investigate: one to trace the data flow, one to check related test
 files, one to look for similar patterns elsewhere in the codebase. Report back and then
 we'll plan the fix."
```

Scale the count to the problem — 5+ subagents for a sprawling or unfamiliar area:

```text
"Before we change anything, fan out subagents to investigate: where this state is
 initialized, every place it's read, every place it's mutated, and how it's tested.
 One subagent per question. Summarize findings, then propose a plan."
```

---

## Parallel implementation

Once there's a plan, split it into **independent** pieces and delegate each:

```text
"Split this into 4 independent changes and have subagents implement each one in parallel."
```

When independence isn't obvious, make the orchestrator establish it first:

```text
"Break the plan into the largest set of changes that don't touch the same files or depend on
 each other's output. Delegate each independent piece to its own subagent; sequence anything
 that isn't independent. Tell me the split before you start."
```

---

## Cross-model review

After changes, hand the diff to a different model (see
[03-cross-model-review.md](03-cross-model-review.md)):

```text
"Now run <other CLI> in a terminal and have it review the diff against main. Report back any
 issues it raises."
```

---

## Iterating on the hints file

When something goes wrong, fix the *system*, not just the instance:

```text
"That was a mistake we've seen before. Update CLAUDE.md with a concise rule so this doesn't
 happen again, then re-do the change following it."
```

```text
"Summarize the recurring corrections from this session and propose additions to CLAUDE.md —
 short, imperative, and specific. Show me the diff before applying."
```

---

## Delegating by success criteria

Per [the ruleset](02-ruleset.md#4-goal-driven-execution), give subagents goals, not step lists:

```text
"Delegate this to a subagent. Success criteria: the new endpoint returns 200 with the user's
 profile, the existing tests still pass, and no unrelated files change. Let it find the path;
 verify the result when it reports back."
```
