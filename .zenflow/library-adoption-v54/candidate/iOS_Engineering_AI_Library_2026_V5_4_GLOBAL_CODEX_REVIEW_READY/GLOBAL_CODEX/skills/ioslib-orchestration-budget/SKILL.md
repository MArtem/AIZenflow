---
name: ioslib-orchestration-budget
description: Use to bound subagent fan-out, depth, context duplication and retries; stop spawning when marginal risk reduction is low.
---

# ioslib-orchestration-budget

## Hardened client-repository contract
- If this workflow may write client files, apply `$ioslib-client-code-protection` before the first edit and verify the predeclared scope afterward.
- Pre-existing dirty work, protected project/config/dependency paths, Git control state and nested repositories are separate authorization boundaries.
- Before uncertain Git/Xcode/dependency/filesystem/network/release commands, use `$ioslib-safe-command-execution`.
- Read-only review/intake work must not create product changes merely to simplify analysis.
## Global installation contract
- This is a user-global skill. Read `references/global-runtime.md` and `references/INSTALLATION.md` first.
- Do **not** expect or create library `.ai`, `.agents`, or `scripts/ai` folders in the client repository.
- For substantial iOS work, use the global project-context command from `INSTALLATION.md` to ensure current external state, then read only relevant generated context.
- Repository-local `AGENTS.md` and repository facts remain more specific and authoritative when they conflict with generic library guidance.
- Load deep library files progressively; never bulk-load the full library.


## Goal
Use to bound subagent fan-out, depth, context duplication and retries; stop spawning when marginal risk reduction is low.

## Mandatory protocol
1. Read applicable `AGENTS.md` and current external generated project context.
2. Read the global runtime `orchestration/ORCHESTRATION_POLICY.md` path from `references/INSTALLATION.md`.
3. Apply the global runtime `orchestration/BUDGETS.md` path from `references/INSTALLATION.md`, write ownership and evidence contracts.
4. Use native subagents only when the current runtime exposes them and this task has explicit delegation authorization from the user or applicable skill/policy.
5. Keep discovery/review agents read-only by default.
6. If native subagents are unavailable, use sequential role passes and say so.
7. Final synthesis belongs to the coordinator; do not return a pile of child summaries.

## Output
Task graph/decision, agent results with evidence, conflicts, integrated decision or patch plan, observed verification, residual risks and unknowns.
