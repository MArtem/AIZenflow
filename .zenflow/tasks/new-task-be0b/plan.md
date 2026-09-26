# Reference quality layer — current plan

Task `new-task-be0b`; updated 2026-09-27; mode `эконом`. V5.4 is removed from the published current tree after copy-only preservation; Git history remains. The candidate is not ready for project use.

## Current two-layer priority

The existing active local rules/prompts/skills are now the **база знаний** (first
layer); the inactive copy-only reference candidate is the **библиотека** (second
layer). The detailed staged plan is `knowledge-base-library-roadmap.md`.
First complete the knowledge-base audit and corrections (A0–A6), then curate
the library (B0–B6) and verify both layers together as an evidence-backed,
multi-layer defense (C0–C3). This terminology change does not rename
paths or activate the second layer.

- [ ] A0/A1: inventory the active knowledge base and trace actual instruction routes.
- [ ] A2–A6: audit, correct and verify the first layer before declaring it stable.
- [ ] B0–B6: account for, curate, evaluate and safely pilot the second layer.
- [ ] C0–C3: prove stage-by-stage joint operation, added defect detection and safe conflict handling.

## Current priority: reverse installed-library effects without losing knowledge

"Factory" means **targeted removal of proven V5.4-owned effects**, preserving existing Codex
settings, chats, plugins and credentials. See `codex-v54-rollback-audit.md`; no general reset.
For reference `ON`, the user chose `AUTO` as default and `ADVISORY` as optional profile; neither
grants extra tool, build, test, agent, Git or host authority.
The future uniquely named copy-only `reference` is the **sole surviving library**: preserve all
useful V5.4 documents, all 60 `ioslib-*` skill workflows/checklists/agent prompts, audit and
recommendation logic. Convert installation-dependent instructions rather than activating them.
Retire only installer, shim, host/Codex mutation and similar deployment mechanisms after source
and consumer accounting; do not delete useful knowledge by directory name.

- [x] Read-only inventory of active Codex surfaces. `~/.codex/config.toml` has no explicit library path/marker; no `ioslib-*` directories were found in `~/.codex/skills`. Do not infer that unrelated app/plugin settings are installation damage.
- [x] The global `~/.codex/AGENTS.md` contained only the installed library block. Preserve its exact bytes at `/Users/Artem/.zenflow/codex-recovery/2026-09-26/AGENTS.md.installed-ios-library` and remove that global file. Hash of backup matched before removal; file absence checked afterward.
- [x] Remove the automatic `v5.4` route and installer-runtime exception from canonical `reusable/GLOBAL_RULES_BOOTSTRAP.md`, leaving the common baseline in place. Isolated commit `8cf58031e49194c4745eb6c016085177358339f0` is on canonical `main` and verified on remote; the task-worktree bootstrap checker passed.
- [x] Audit the known host/project instruction entrypoints and exact runtime ownership. The new chat found no automatic route to `v5.4`; `~/.codex/config.toml` had no explicit library reference; five runtime-managed file hashes matched the installation registry. Process enumeration failed, so absence of active old consumers is **unknown**.
- [x] A separate new chat read the current instruction chain: project/parent AGENTS → canonical bootstrap → common baseline/router. It found no global `~/.codex/AGENTS.md` and no automatic installed-library route. This validates the instruction chain in that new chat, not a full app restart or the absence of old running consumers.
- [x] After the user fully closed/restarted Codex, move the exact eight-file ignored runtime subtree to `/Users/Artem/.zenflow/codex-recovery/2026-09-26/ios-engineering-installed-runtime`. The prior path is absent; five managed-file hashes match the registry in quarantine. No auth/Keychain change.
- [x] Preserve useful source, remove all 1,367 tracked V5.4 files from the current tree, and publish documentation-vault commit `3e2c7c5` on `main` without rewriting Git history. Coverage: 823 exact copies, 514 permission-conditional transformations, zero missing mapped useful files, five intentional deployment/test exclusions. See `MIGRATION_COVERAGE_RECEIPT.md`.
- [x] Obtain post-runtime-move fresh-chat evidence after a full Codex restart: project/common rules loaded; the checked active chain had no V5.4 route; old current-tree/runtime paths were absent. This does not prove every external consumer or host setting is absent.
- [x] Define `reference ON → AUTO` by default and optional `ADVISORY` as separate execution profiles in the inactive candidate; automatic means in-session reasoning inside current permissions, not background tools or installation.
- [x] Preserve all 240 former `ioslib-*` skill files byte-identically under inactive `reference-copy-only/source-skills/`; recursive diff passed and no symlinks were present. They are not installed or allowlisted yet.
- [x] Preserve 49 former runtime Markdown/JSON documents under inactive `source-runtime/` and 11 client-protection documents under inactive `source-protection/`; exact comparisons passed and no executable runtime files were imported. Curate a copy-only repository-safety route without the old CLI.
- [x] Create an inactive provisional A0/A1/A2/X action-ranking ledger for migrated V5.4 behaviors. Final always-auto versus advice-only choices remain for the user's later reference-mode decision; no rank grants command authority.
- [ ] Convert every useful old skill workflow, checklist and agent prompt into self-contained copy-only guidance; inventory and resolve installer/runtime-dependent text before allowing any converted skill route.
- [x] Publish canonical bootstrap rollback as `8cf5803`, then separately publish current-tree cleanup and the inactive copy-only candidate as `3e2c7c5` after coverage and final-diff checks. Publication does not activate the candidate.
- [x] Publish a separate V5.4 retirement status record in AIZenflow `main` and `development` as atomic commit `9f626dbd3`, without merging this task branch or overwriting their active plans. Both remote SHAs were verified.

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

## Bounded implementation units — report at meaningful boundaries

### Precondition: retire installation before new reference work
- [x] The six mixed uncommitted installer changes in canonical `v5.4` were explicitly discarded on 2026-09-26; canonical worktree was verified clean. Do not resurrect or commit them.
- [x] Account for installer, shim, CLI and runtime behavior, preserve useful concepts in inactive copy-only routes and `LEGACY_CAPABILITY_MAP.md`, then remove deployment-only executables from the published current tree. Do not reactivate old runtime behavior or claim functional parity.
- [x] Extract useful **scenario categories** from the retired test suite into inactive `LEGACY_TEST_SCENARIO_MAP.md`; installer/host-manipulation fixtures are excluded and the old tests do not validate `reference`. The original tests were removed with the retired current-tree package.
- [x] After the user's correction, preserve the four useful `40_REPO_AUTOMATION` script sources byte-for-byte in inactive `reference-copy-only/source-tools/`; they are excluded from the payload and not runnable yet. Do not confuse removal from the retired `v5.4` tree with loss of their source. `validate_ai_layer.py` is installation-layout-specific; retain its useful metadata-validation principle in the copy-only manifest instead.
- [ ] Port the preserved audit scripts into bounded, self-contained, read-only `reference` utilities only after reviewing failure semantics and invocation permissions. In particular remove `swift_risk_scan.py`'s old protection import and `verify_diff.sh`'s suppressed scanner failure. Do not activate source copies as-is.
- [x] **Safety boundary:** the installed runtime is quarantined, the former active path is absent and useful historical V5.4 source remains recoverable in Git and inactive copies. No further host/system mutation is authorized.
- [x] The separate named copy-only plan was committed and pushed to AIZenflow `development` and `main` without merging this task branch or overwriting main's active `plan.md`. The task branch remains; do not delete it until its unique history is accounted for.
- [x] AIZenflow main's different active `new-task-be0b/plan.md` was preserved; the reference plan used a separate named artifact.

### 0. Re-enter safely
- [x] Read the canonical bootstrap, routed Level 0, current plan/handoff, package rules and only affected files. Inspect Git state and preserve pre-existing changes. Confirm documentation/knowledge-only scope.
- [ ] Before each patch state expected behavior, authority, stage ordering, affected consumers, failure result and verification. Limit each unit to 2–3 related documents, with one relevant static check and `git diff --check` at the unit boundary. Ask before expanding scope.

### 1. Define the two-mode quality contract
- [ ] Create one canonical app-neutral reference-controller contract under `documentation-vault/reusable/` after checking nearby naming conventions. Define OFF and ON pipelines, precedence, stage inputs/outputs, no-mutation review, severity, fail-closed/insufficient evidence, switching and candidate readiness.
- [x] Distinguish `quality reviewed`, `runtime verified`, `ready for user review` and `ready for PR` in the candidate evidence policy. Do not use `ideal`, `safe` or `passed` without matching evidence.
- [x] Confirm OFF includes full local inspection, test decisions and final-diff review; ON adds a reference pass at **every** stage, not just the end.
- [ ] Define task-shaped outputs: advice/review gets evidence-backed findings or recommendations; implementation gets a reviewed candidate diff; design-to-code gets design-fidelity plus iOS-quality evidence. The same quality standard applies, but output and verification differ by task type.
- [ ] Treat every generated/edited iOS code or resource artifact as a deliverable requiring source/ownership review, relevant consumer checks, task-appropriate verification and final complete-diff review. Report missing build, visual, device or localization evidence honestly; do not call an unverified artifact PR-ready.
- [ ] Add a change-surface checklist for target/package/resource/localization changes: intentional membership and ownership, dependency direction, resource-bundle lookup, extension safety, localization/RTL/accessibility, supported toolchain and platform range, supply-chain/privacy implications, affected build/test/QA evidence and rollback/compatibility. Apply only the relevant rows to the actual task.

### 2. Visible project control without client-repository infrastructure
- [x] Specify a tiny external per-project consent/status record under the user-selected `documentation-vault/tasks/reference-status/`, not in a client repository. Define linked worktrees, moved roots and invalid records; no actual project record has been created.
- [ ] Add one minimal reusable startup rule: read local rules first, read the project mode, show `Reference: ON/OFF/UNSET`, ask once when UNSET, and behave as OFF when state is missing/invalid/ambiguous. Do not alter Codex global settings or host AGENTS.
- [x] Document a **conversational interface, not an existing CLI**: `reference status`, `on`, `off`, `review`, `help`, `config`. These are not yet implemented or active.
- [x] Specify that a new project starts UNSET and existing projects read only their own record. No cross-project inheritance or automatic insertion into an app repo.

### 3. Coherent, bounded knowledge routing
- [ ] Resolve the conflicting historical `source-global/KNOWLEDGE_ROUTER.md` and `source-meta/START_HERE.md` behavior in one copy-only primary router, common baseline, at most two evidenced supporting routes and no whole-corpus loading. The old current-tree paths are removed; check every copied route before activation. Local project material is evaluated before reference at each stage.
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
- [ ] Do not activate or deploy the published-but-incomplete reference candidate, create a PR, install, enable on a live project or touch the host without a new explicit authorization. Future changes need their own review before publication.

## Current copy-only migration evidence

- User chose `documentation-vault/tasks/reference-status/` for local ignored ON/OFF state and separate status for each Xcode project even within one Git repository. The candidate defines project identity, its record and conversational interface, but no real record, startup activation or cross-chat behavior exists yet.
- Canonical `reusable/ios-engineering-library/reference-copy-only/` is committed but inactive. It contains a quality/evidence/router core and curated general review, build/package/resource, accessibility/localization, Figma-to-iOS, Swift concurrency, networking, persistence, test-strategy and security/privacy routes. Imported source playbooks are still outside the active allowlist. The curated-file Markdown links passed a static existence check; paper scenarios are not executed comparison evidence.
- The 35 thematic directories `01–35` contain 813 copied Markdown files. Exactly 514 copied files received the user-approved permission-conditional boilerplate rewrite; per-file comparison against the expected transformation of unchanged `v5.4` sources passed. Most thematic files remain unrouted and unreviewed.
- The complete `36–49` non-executable corpus is now preserved in inactive `legacy-source/`: 186 Markdown files and three JSON agent templates. Recursive comparison differs only by five excluded executable automation scripts. All 189 remain unrouted; installer/runtime wording must be removed before final-payload selection.
- The former ignored runtime descriptor is quarantined outside its active path; no host/Codex settings, auth, Keychain, installer or client repository was modified during this content pass. Do not activate or deploy the incomplete candidate.
- Curated architecture, UI-flow, full-project audit and bounded agent-coordination routes are now allowlisted in the inactive candidate. The full audit inventories all applicable domains and separates checked from unverified; coordination does not grant agent invocation authority.
- Current-tree cleanup is published: all 1,367 old V5.4 tracked files and five obsolete user-delivery installation documents are absent at the old path. The canonical README and generated manifests point to the inactive candidate; manifest, vault, link and final-diff checks passed. Useful section 12 of the old user guide became inactive `USER_WORKFLOW_RU.md`.
- Next: review candidate link/authority safety, adapt the four preserved read-only audit scripts, validate OFF/ON scenarios and state behavior without live activation, and review future candidate changes before any further publication. Do not claim `reference` is already active. Status control remains a design question, not an implemented utility.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
