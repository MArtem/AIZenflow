# Current Plan

## Goal

Prepare the iPhone-only, Simulator-verifiable App Intents / Shortcuts phase in independently reviewable blocks. The durable discrete architecture, blocks A1–A5, tutorial track, and deferred runtime scope are canonical at:

`/Users/Artem/.zenflow/worktrees/documentation-vault/apps/AIFieldbook/plans/app-intents-discrete-implementation-plan.md`

## Active Constraints

- Active mode: `сбалансированный`; bounded implementation uses `GPT-5.6 tera`, `medium`.
- Work one self-contained code iteration at a time, then stop for user-run build/UI QA.
- Do not run builds, tests, Simulator UI, screenshots, Instruments, archive, signing, or device work unless the user specifically delegates it.
- Do not start App Intents runtime code until the user explicitly accepts gate `1.26-S`.
- Preserve all existing uncommitted changes; do not create tests, a backend, provider credentials, cloud infrastructure, App Groups, or a destructive SwiftData migration.
- iPad is out of product, acceptance, and release scope.

## Current State

- [x] `1.26-S` was explicitly accepted by the user. The Simulator-verifiable App Intents subset is open; `1.26-D` remains device-only and closed.
- [x] The accessible workspace empty/error-state remediation was implemented and user-reported as visually acceptable.
- [x] Workspace and text-note detail loading blank-screen defects were remediated and user-reported as functional.
- [x] A1 — Open Workspace vertical slice was implemented: a privacy-minimal `WorkspaceEntity`, bounded local query, and validated deep-link handoff.
- [x] A1 was built and installed during the user-authorized Shortcuts investigation; no tests were created or run.
- [ ] A1 Shortcuts runtime verification is blocked by a confirmed iOS 26.5 Simulator / `linkd` regression. The same unsigned TchopApp provider registers normally on a clean iOS 18.2 Simulator; no signing workaround is approved.
- [x] A2 — Find Knowledge Items implemented as its own bounded local-discovery slice. A1/A2 data source, entities, and intents are separated into dedicated files; the agent-built Debug app installed and reached the iPhone Simulator UI without a crash. Shortcuts runtime remains blocked by the known iOS 26.5 Simulator regression.

## Next Executable Step

Present only the exact A2 proposal. Do not begin code until the user accepts its bounded scope. Keep A1 runtime evidence explicitly blocked by the iOS 26.5 Simulator regression; do not add signing, device work, or a workaround without separate approval.

## Context Transfer Rule

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
