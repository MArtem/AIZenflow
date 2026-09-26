# Reference quality layer — current plan

Task `new-task-be0b`; 2026-09-26; operating mode `эконом`. This plan supersedes the completed V5.4 acceptance plan. Its historical evidence remains at `../library-adoption-v54/evidence/final-acceptance/final-acceptance-summary.md`. No implementation of this plan has begun.

## Approved outcome and hard boundaries

- `reference OFF`: apply **all** relevant local project rules, knowledge, inspections, permitted test writing/execution, code review, and complete candidate-diff review. OFF does not lower the quality bar.
- `reference ON`: do the same full local workflow **first**, then apply the separate reference quality layer at planning, design, implementation review, verification review, and final whole-diff pre-PR review. Resolve findings and recheck the affected stage. ON is additive, not a final-only check.
- This contract covers **every task in an opted-in project**, not only coding: review, advice, diagnosis, fixes, new features, documentation/design decisions, and Figma-resource-to-iOS-screen work. Choose task-appropriate local and reference gates; never force a code diff, build, or iOS-specific check onto a task where it is not applicable. For a Figma screen, preserve design-source fidelity, project design system, responsive/accessibility behavior and evidence limits through design, implementation and final review.
- **Any assistant work that outputs new or changed iOS code or app resources** (assets, localized strings, UI/layout resources, project-bound configuration and similar deliverables) must pass the task-appropriate local quality stages before handoff. When reference is ON, the additive reference check applies at each applicable stage and to the complete final code/resource diff. A resource is not exempt merely because it is not Swift source.
- The same pre-handoff gate covers the **entire iOS developer change surface**: Xcode projects/workspaces, target and scheme membership, build phases/settings, module or package boundaries, SwiftPM/dependencies, source, generated code, assets/resource catalogs, localization, entitlements/capabilities, extensions/widgets and relevant tests/docs. Verify the affected producer and every consumer (including app, extension and package targets) before presenting a candidate to the user for their own review, commit or PR. Never present a partial code-only review as a full change review.
- Give the user the best evidence-backed candidate diff for their own review. Never promise literally perfect code or claim an unrun check passed. P0–P2 and missing required evidence block a ready-for-PR claim. PR creation is a separate user decision.
- Per-project `ON`/`OFF`/`UNSET` is visible in meaningful status reports and survives a new chat. At UNSET, ask once on project entry; default OFF until answered. ON/OFF can change during a task and affects future reference passes, not local quality gates.
- Local rules and project knowledge have priority. Reference is an advisory quality layer, not higher policy authority or independent review when the same agent performs it.
- The user has retired **all installation modes**, including the former installed `reference`. The target is a **copy-only knowledge-and-quality library**: its approved files are copied into a project only for an explicitly authorized project task and operate below that project's local rules. Never run an installer, modify the host, auth, Keychain or system/Codex settings. No client project is changed by this planning task. Preserve unrelated dirty work. Work stays inside `/Users/Artem/.zenflow`.
- This task does not authorize running builds/tests/Simulator/Instruments or mutating production projects. Future project tasks may authorize these separately. Test writing belongs to the quality workflow when that task permits test edits; the goal itself does not grant runtime-execution authority.

## Discrete Luna implementation units — stop and report after each

### Precondition: retire installation before new reference work
- [ ] The six mixed uncommitted installer changes in canonical `v5.4` were explicitly discarded on 2026-09-26; canonical worktree was verified clean. Do not resurrect or commit them.
- [ ] Inventory **already tracked** installer, shim, host-modification, protection and system-state files plus docs/manifests/tests that depend on them. Design a reviewed copy-only payload so removing installers does not delete the knowledge corpus or leave broken references. **User decision: remove from the current tree by a new commit; preserve old Git history. No history rewrite or force-push.**
- [ ] **Safety hold:** the existing ignored runtime descriptor still selects canonical `v5.4` as its `knowledge_root` and its `GLOBAL_CODEX/runtime/bin/ios_ai.py` as `runtime_cli`. Do not delete or mutate that source-in-place payload while it may be live; first design a separate copy-only source/release and obtain an explicit safe cutover decision. No host/system mutation is authorized by this plan.
- [ ] Move only the validated current plan/copy-only changes to the intended `development` and `main` branches. `origin/main` and `origin/development` of AIZenflow currently resolve to the same SHA, while the task branch has 21 additional commits; do **not** merge that branch wholesale or delete it until every unique needed artifact is accounted for. Do not commit/push a broken intermediate package.
- [ ] AIZenflow `origin/main` has a different active `new-task-be0b/plan.md`; do not overwrite it with this branch's plan. Choose a separate named plan artifact or another explicit task-state boundary before transferring the reference plan.

### 0. Re-enter safely
- [ ] Read the canonical bootstrap, routed Level 0, current plan/handoff, package rules and only affected files. Inspect Git state and preserve pre-existing changes. Confirm documentation/knowledge-only scope.
- [ ] Before each patch state expected behavior, authority, stage ordering, affected consumers, failure result and verification. Limit each unit to 2–3 related documents, with one relevant static check and `git diff --check` at the unit boundary. Ask before expanding scope.

### 1. Define the two-mode quality contract
- [ ] Create one canonical app-neutral reference-controller contract under `documentation-vault/reusable/` after checking nearby naming conventions. Define OFF and ON pipelines, precedence, stage inputs/outputs, no-mutation review, severity, fail-closed/insufficient evidence, switching and candidate readiness.
- [ ] Distinguish `quality reviewed`, `runtime verified`, `ready for user review` and `ready for PR`. Do not use `ideal`, `safe` or `passed` without matching evidence.
- [ ] Confirm OFF includes full local inspection, test decisions and final-diff review; ON adds a reference pass at **every** stage, not just the end.
- [ ] Define task-shaped outputs: advice/review gets evidence-backed findings or recommendations; implementation gets a reviewed candidate diff; design-to-code gets design-fidelity plus iOS-quality evidence. The same quality standard applies, but output and verification differ by task type.
- [ ] Treat every generated/edited iOS code or resource artifact as a deliverable requiring source/ownership review, relevant consumer checks, task-appropriate verification and final complete-diff review. Report missing build, visual, device or localization evidence honestly; do not call an unverified artifact PR-ready.
- [ ] Add a change-surface checklist for target/package/resource/localization changes: intentional membership and ownership, dependency direction, resource-bundle lookup, extension safety, localization/RTL/accessibility, supported toolchain and platform range, supply-chain/privacy implications, affected build/test/QA evidence and rollback/compatibility. Apply only the relevant rows to the actual task.

### 2. Visible project control without client-repository infrastructure
- [ ] Define a tiny external per-project consent/status record inside the approved `.zenflow` documentation/state boundary, not in a client repository. Specify stable identity and handling of moved roots, linked worktrees, absent, duplicate or malformed records. Store only mode and minimal preferences, never code bodies, credentials or logs.
- [ ] Add one minimal reusable startup rule: read local rules first, read the project mode, show `Reference: ON/OFF/UNSET`, ask once when UNSET, and behave as OFF when state is missing/invalid/ambiguous. Do not alter Codex global settings or host AGENTS.
- [ ] Document a **conversational interface, not an existing CLI**: `reference status`, `on`, `off`, `review`, `help`, `config`. State scope, transitions, and confirmation for preference changes. Safety and local-rule precedence are not configurable.
- [ ] New project starts UNSET; existing project reads only its own record. No cross-project inheritance or automatic insertion into an app repo.

### 3. Coherent, bounded knowledge routing
- [ ] Align `v5.4/GLOBAL_CODEX/KNOWLEDGE_ROUTER.md` and `v5.4/00_META/START_HERE.md`: one primary route, common baseline, at most two evidenced supporting routes, no whole-corpus loading. Local project material is evaluated before reference at each stage.
- [ ] Separate implementation guidance from review guidance and select by actual task evidence. Never assume SwiftUI, architecture, persistence or packages for an unknown project. Check affected mirrored claims without modifying installer/runtime documentation.

### 4. Focused content correction
- [ ] Inventory off-topic instructions (known example: AI evals in feature-flags/RTL playbooks), repeated boilerplate, stale paths and contradictions in daily-use routes.
- [ ] Fix priority batches of 2–3 documents. Compare each to its source skill and real iOS failure modes; report remaining inventory instead of silently sweeping hundreds of files. Keep package mechanisms distinct from app-specific policy.

### 5. End-to-end quality scenarios
- [ ] Define a scenario matrix: code review, advice/design proposal, feature, unknown bug, fix, concurrency, networking, persistence, tests, documentation, target split, package extraction/integration, dependency change, asset/resource addition, localization, PR review, new-project intake and Figma resources → iOS screen. For each trace local facts/invariants → task-appropriate local work/verification → reference checks at each applicable stage when ON → corrected output → complete final diff **whenever any project artifact changed**.
- [ ] For Figma-to-screen, check supplied design identity/variants, assets, component states, layout across supported sizes, accessibility/localization and screenshot or visual comparison only when authorized and available. Missing design access or visual evidence is `INSUFFICIENT_EVIDENCE`, never pixel-perfect PASS.
- [ ] Cover ON, OFF, UNSET, mid-task switch, conflicting advice, missing materials, unrun tests, P0–P2, altered diff after review, unknown deployment, old/new/linked project identity. New edits invalidate a final review receipt.
- [ ] Compare OFF and ON offline on identical fixed tasks: true findings, false positives, local-rule compliance, actionable fixes, context cost and evidence honesty. No host adoption or real-client mutation.

### 6. Final review and handoff
- [ ] Inspect complete final documentation diff and affected consumer claims. Obtain one independent Sol/high review after Luna's focused edits. Fix P0–P2 in a separately bounded iteration and re-review once; avoid an unbounded correction loop.
- [ ] Report changed files, static results, offline evaluation limits, residual risk and user-owned runtime evidence. Do not claim automatic cross-chat behavior until the startup rule and project record are checked in a fresh chat.
- [ ] Do not commit, push, create PR, install, enable on a live project or touch the host without a new explicit authorization.

## Decision before unit 2

The user approved persistent **project** status and one startup rule, but not a particular storage path. Resolve the external project-record location and stable identity with the user before writing it. Never quietly create a client-repository file or system setting.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
