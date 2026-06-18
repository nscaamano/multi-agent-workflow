# Attribution

This repository combines two sources.

## The multi-agent workflow

The orchestrator + worker workflow, the parallel-subagent pattern, the hints-file practice,
the cross-model review idea, and the six-step replicate loop are drawn from the author's own
reference guide, *Multi-Agent Coding Workflow*. That guide is the basis for
[docs/01-workflow.md](docs/01-workflow.md), [docs/03-cross-model-review.md](docs/03-cross-model-review.md),
and [docs/04-prompt-library.md](docs/04-prompt-library.md).

## The behavioral ruleset

The four behavioral principles in [docs/02-ruleset.md](docs/02-ruleset.md) — Think Before Coding,
Simplicity First, Surgical Changes, and Goal-Driven Execution — are adapted from:

> **andrej-karpathy-skills** by forrestchang
> <https://github.com/multica-ai/andrej-karpathy-skills>
> Licensed under the MIT License. Derived from Andrej Karpathy's observations on common LLM
> coding pitfalls.

The principles have been reworded and merged into a single ruleset with orchestration-aware
notes tailored to this workflow, rather than copied verbatim. The original is distributed as a
Claude Code plugin / skill; here they are presented as plain reference documentation.

This repository is itself licensed under the [MIT License](LICENSE), which is compatible with
the source material.
