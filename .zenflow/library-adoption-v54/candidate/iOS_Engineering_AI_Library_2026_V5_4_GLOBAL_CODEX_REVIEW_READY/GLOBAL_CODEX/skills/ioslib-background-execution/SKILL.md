---
name: ioslib-background-execution
description: Use for BGTaskScheduler, background URLSession, silent push, processing/refresh tasks, app lifecycle transitions, extension work, or background execution reliability.
---

# Background Execution

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
Design background work around system budgets, idempotency, cancellation, expiration and observable recovery.

## Start
1. Read applicable `AGENTS.md` files and repository facts plus external generated project context.
2. If project facts are missing and materially affect the task, use `$ioslib-repo-intake` or inspect them directly.
3. Apply risk/evidence rules from the global runtime `core/V2_EXECUTION_PROTOCOL.md` path from `references/INSTALLATION.md` and the global runtime `core/EVIDENCE_CONTRACT_V3.md` path from `references/INSTALLATION.md` when present.
4. Use the global runtime `core/SKILL_TO_LIBRARY_MAP.md` path from `references/INSTALLATION.md` to load only a matching deep playbook.

## Workflow
- Define the observable outcome or review question.
- Separate inspected facts from assumptions.
- State 3–10 task-specific invariants for R1+ work.
- Inspect owners, callers/consumers and affected targets before editing.
- For R2+, compare at least two viable approaches and account for migration/rollback.
- Make or recommend the smallest coherent change that preserves repository conventions.
- Verify the highest-risk negative path and use exact repository commands rather than invented ones.
- Review the final diff/findings for concurrency, lifetime, availability, security/privacy, performance and accessibility where applicable.

## Domain checks
Load `references/domain-checklist.md` for the focused checklist.

## Output
Report: mode/risk, facts/assumptions, invariants, decision, changed files/findings, exact observed verification, cross-cutting impact, rollback/containment, and unknowns. Never claim unobserved validation.
