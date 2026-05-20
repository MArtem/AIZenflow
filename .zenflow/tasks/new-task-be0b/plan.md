# Current Plan

## Goal
Keep `TchopApp` implementation and documentation aligned with the current product contract while minimizing unnecessary complexity, context churn, and verification cost.

## Active Focus
- Feed/composer/card runtime for `text`, `photo`, `video`, `audio`, `pdf`.
- Documentation/rules are now part of the active working baseline.
- Current user overrides are canonical for this task and live in `./docs/CURRENT_USER_OVERRIDES.md`.

## Active Steps
No open implementation step is currently queued in this plan.

## Current Working Baseline
- Use `GPT-5.5` for this worktree/task unless the user explicitly changes the model.
- Before substantive work or context transfer, use the active docs index in `./docs/README.md`.
- Always include the context-transfer rule: **"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.
- Do not run builds, tests, or simulator UI unless the user explicitly asks.
- Do not touch `./TchopAppTests` unless the user explicitly asks.
- Prefer the simplest correct implementation; avoid speculative UI, speculative logic, and decorative abstractions.

## Canonical Docs Added/Refreshed
- `./docs/CURRENT_USER_OVERRIDES.md`
- `./docs/UI_PIXEL_PERFECT_WORKFLOW.md`
- `./docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md`
- `./docs/agent-prompts/README.md`
- `./.codex/skills/tchop-feed-cards/references/feed-card-contract.md`
- `./docs/knowledge/global/README.md`
- `./docs/knowledge/TchopApp/README.md`
- `./PROJECT_DOCUMENTATION.md`

- Completed now: hardened `./.gitignore` for privacy/CI signing safety (added iOS build artifacts, local env files, Apple signing/provisioning files, private keys/tokens/service-account patterns, Fastlane generated secrets/output, and CI secret material; verified tracked secret-like path scan returned empty and docs remain unignored).
- Verification: static git-ignore checks only; no build run per current instruction.

## Verification Status
- This latest cleanup is docs-only.
- No build/test/simulator verification was run.

## Archive
Detailed historical plan/log entries were moved out of the active plan to reduce context cost.
Global reusable knowledge and TchopApp-specific knowledge are now split under `./docs/knowledge/`.

Use archives only when historical detail is needed:
- `./.zenflow/tasks/new-task-be0b/archive/plan.before-cleanup-2026-05-20.md`
- `./.zenflow/tasks/new-task-be0b/archive/plan.legacy.md`
