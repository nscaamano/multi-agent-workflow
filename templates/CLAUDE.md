# CLAUDE.md

> Drop-in hints file. Copy this to the root of your project, fill in the placeholders, and
> grow it over time. Works as `CLAUDE.md` or `AGENTS.md`. The behavioral rules below are a
> condensed mirror of `docs/02-ruleset.md` in the multi-agent-workflow repo — keep them, and
> replace the project-specific sections with your own.

## How this project uses the multi-agent workflow

- The main session is the **orchestrator**. Delegate real work to focused subagents rather than
  doing it all in one context.
- **Investigate in parallel** before planning; **split implementation** into independent pieces.
- After non-trivial changes, run a **cross-model review** of the diff against `main`.
- When you correct me on something, I should add a rule to this file so it doesn't recur.

## Behavioral rules

1. **Think before coding.** State assumptions explicitly. If a request is ambiguous, ask before
   building — don't silently pick one interpretation.
2. **Simplicity first.** Write the minimum code that solves the problem. No speculative features,
   single-use abstractions, or error handling for impossible cases.
3. **Surgical changes.** Touch only what the task requires. Match existing style. Remove only the
   imports/functions your own change orphaned; don't refactor or delete unrelated code unasked.
4. **Goal-driven execution.** Work to explicit success criteria and verify before declaring done.
   For multi-step work, outline a brief plan with a verification step for each part.

## Project context

<!-- Fill these in. Delete what doesn't apply. -->

- **Stack:** <!-- e.g. TypeScript, React, Node, Postgres -->
- **Package manager / runtime:** <!-- e.g. pnpm, uv, cargo -->
- **Run / build:** <!-- e.g. `pnpm dev`, `make build` -->
- **Tests:** <!-- e.g. `pnpm test`; what counts as "passing" -->
- **Lint / format:** <!-- e.g. `pnpm lint`, biome, ruff -->

## Conventions

<!-- Code style, naming, file layout, patterns to follow or avoid. -->

-

## Gotchas

<!-- Add a line every time the agent makes a mistake, so it doesn't repeat it. -->

-
