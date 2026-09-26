# Copy-only iOS quality library — implementation plan

Date: 2026-09-26. This is a separately named work package: do not replace the active `plan.md` on AIZenflow `main`/`development`. User-approved goal: retire installation, preserve the knowledge library, and deliver an opt-in per-project quality layer. Old Git history remains; no force-push.

## Non-negotiable contract

1. The library is **copy-only** for a project after explicit scope approval. It never installs into Codex, changes host/system settings, auth or Keychain, or runs an installer. Local project rules and knowledge remain authoritative.
2. Project state is `ON`, `OFF` or `UNSET`, visible in meaningful reports and persistent across new chats. At `UNSET`, ask once and act as OFF until answered. `reference status/on/off/review/help/config` are proposed chat commands, not an existing CLI. Changing mode affects future reference passes, not local gates.
3. `OFF` still performs the complete task-appropriate local engineering workflow: requirements, relevant code/resource ownership and consumers, implementation, permitted test writing/execution, review, evidence, and complete final diff before user handoff.
4. `ON` performs that **same local workflow first** and adds the reference layer at each applicable stage: planning, design, change, verification and final complete-diff review. Findings are corrected and the affected stage rechecked. Reference never overrides local rules or grants tool/command authority.
5. This applies to every task in the opted-in project: advice, review, diagnosis, fix, feature, Figma-to-screen, target/package split, dependencies, assets, resources, localization, extensions, tests and documentation. For code/resource changes, review the entire affected build graph and every consumer, not only Swift source. For advice-only tasks, return evidence-backed findings without inventing a diff.
6. The output is the strongest **evidence-backed** candidate for user review before commit/PR, not a literal perfection guarantee. P0–P2 or missing required evidence block a ready-for-PR claim. Unrun builds, tests, device/visual checks and independent reviews are reported, never converted to PASS. Commit/PR are separate user decisions.

## Safety prerequisite — before editing the published library

- [ ] Keep the canonical `v5.4` source untouched while the existing runtime descriptor still names it as `knowledge_root` and its CLI as `runtime_cli`. The six mixed uncommitted installer changes were discarded; do not resurrect them.
- [ ] Inventory tracked installer/shim/host/protection/system-state code, tests, documentation, manifests and references. Design a separate copy-only payload first; avoid breaking the active source-in-place runtime or deleting knowledge by accident.
- [ ] User decision: remove installation artifacts from the **current tree** by a reviewed new commit when safe; retain old Git history. No history rewrite/force-push and no host cutover under this plan.
- [ ] Migrate this plan alone to AIZenflow `development`/`main`; the task branch contains 21 unique commits and must not be merged wholesale or deleted until all unique needed material is accounted for.

## Luna units — one bounded, reviewable unit at a time

### 0. Re-enter and freeze scope
- [ ] Read canonical bootstrap, routed Level 0, current task handoff/plan, exact source-of-truth and package rules. Inspect status before writing; preserve unrelated dirty work.
- [ ] Before each patch state behavior, authority, ordering, consumer impact, failure result and check. Limit a unit to 2–3 related documents unless the user expands scope. Stop on a repeated correction loop.

### 1. Two-mode quality contract
- [ ] Put one app-neutral controller contract in the canonical reusable-document boundary. Specify OFF/ON stage graph, local-first precedence, severity, evidence, failure/insufficient-evidence semantics and mode transitions.
- [ ] Define task-shaped outputs and statuses: advice findings, review findings, implementation candidate diff, design/resource fidelity evidence; `quality reviewed`, `runtime verified`, `ready for user review`, `ready for PR` must not be conflated.

### 2. Project visibility and control
- [ ] Define a minimal external per-project consent record under the approved `.zenflow` boundary, not a covert client-repository infrastructure copy. Resolve exact location and stable identity with the user before writing; handle new, moved, linked, missing, duplicate and corrupt project records fail-closed.
- [ ] Add one small reusable startup rule that reads local rules first, displays `Reference: ON/OFF/UNSET`, asks once at UNSET, and never silently inherits another project's choice. Document proposed chat commands and fixed, non-configurable safety rules.

### 3. Bounded routing and content correction
- [ ] Reconcile `GLOBAL_CODEX/KNOWLEDGE_ROUTER.md` with `00_META/START_HERE.md`: common baseline, one primary task route, at most two evidenced supports, no whole-corpus loading. Separate implementation from review guidance.
- [ ] Inventory off-topic and repeated playbook text, stale installer paths and conflicting claims. Correct prioritized daily-use routes in batches of 2–3 files, checking each against its source skill. Report remaining work instead of an unreviewed sweep.

### 4. Whole-surface engineering gates
- [ ] For each task use relevant source/ownership, target/scheme/build phase/settings, module/package/dependency, resource-bundle, extension, asset, localization/RTL/accessibility, privacy/capability, compatibility and test/QA checks. Do not impose irrelevant gates.
- [ ] Include Figma resource identity, component states, layout variants and visual comparison when authorized. Missing design/visual evidence is `INSUFFICIENT_EVIDENCE`, not pixel-perfect PASS.
- [ ] New edits after final review invalidate that review receipt. Review the complete project-artifact diff before handing it to the user.

### 5. Offline evaluation and final review
- [ ] Compare OFF/ON on identical fixed scenarios: review, advice, feature, bug, concurrency, API, persistence, target/package/resource/localization change, Figma screen and new-project intake. Measure true/false findings, local-rule compliance, actionable fixes, context cost and evidence honesty. No live host or real-client mutation.
- [ ] Check ON/OFF/UNSET, mid-task switch, local/reference conflict, unrun verification, P0–P2, unknown project facts and changed diff. Do only permitted static checks; user-owned build/test/device evidence remains explicitly pending.
- [ ] Sol/high independently reviews the final diff after Luna's bounded edits. Close P0–P2 or report not-ready; one complete re-review after fixes. Do not claim cross-chat activation until verified in a fresh chat.

## Publication and cleanup gate

- [ ] No installer-related source/docs deletion from live `v5.4` until a safe copy-only successor and source-use decision exist. No commit or push of a broken intermediate package.
- [ ] Before any authorized commit/push: review exact full diff, static checks, target branch freshness, and absence of auth/Keychain/host changes. Push only the reviewed SHA to intended refs; verify remote parity.
- [ ] Delete a temporary branch only after proving its unique needed commits/content exist on `development`/`main`; otherwise retain it. Any cleanup must name exact targets and recoverability.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
