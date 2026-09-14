# Repository Orchestration Policy

Use multi-agent execution only through `$ioslib-multi-agent-orchestrator` or another V5 orchestration skill. Default to single-agent for R0–R1. Default budgets: 4 children/wave, 8 total, depth 1. Parallel reviewers/scouts are read-only; concurrent writers require independent repositories/clones with different Git common directories and disjoint ownership. Linked worktrees are serialized for write sessions. Shared files belong to the integrator. Agent conclusions are not evidence. Native subagents are feature-detected; sequential role passes are the fallback.
