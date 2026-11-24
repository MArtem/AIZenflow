# Reusable KB quality improvements — execution plan

- Task ID: `kb-reusable-quality-2026-11-20`
- Goal: make reusable knowledge more trustworthy, discoverable, safe to apply, and efficient for future projects.
- Canonical source: `/Users/Artem/.zenflow/worktrees/documentation-vault`.
- Active worktree: `/Users/Artem/.zenflow/worktrees/knowledge-base-next`.
- Mode: `качество`; current model route is adequate.

## Scope and change contract

**Behavior:** future-project agents can identify source, owner, freshness, authority, and unresolved facts before relying on reusable claims. Skills resolve through governed entrypoints. Package verification preserves state it does not own and never reports an unavailable check as PASS. Startup routes select required context without forcing unrelated indexes or app overlays.

**Authority:** reusable guidance lives under the canonical `reusable/` tree; `reusable/baseline/` distributes the shared baseline. App decisions and exceptions remain under the matching app/task boundary. Historical inventories remain historical receipts.

**Agreement and state:** source revision, license scope, API freshness, catalog refresh, scratch ownership, and runtime evidence may be unknown. Keep `UNKNOWN`, `UNVERIFIED`, `UNAVAILABLE`, and `NOT RUN` distinct. Never infer success from file presence or an old receipt.

**Failure/resource semantics:** imported references never execute automatically. Package verification remains fail-closed unless its paths, cleanup ownership, resource limits, and permitted success/failure scenarios are established. At plan approval, tests, builds, Simulator/UI, runtime verifier execution, and project-repository Git actions were not authorized; canonical documentation-repository commit/push was authorized by repository instructions. On 2026-11-25 the user explicitly authorized commit/push of this accumulated KB audit change set to existing `main` and `development` branches. That later instruction supersedes only the project Git restriction; it does not authorize runtime or test work.

## Plan and progress

### 0. Baseline and task record — complete
- [x] Read task-relevant model, source-of-truth, document-boundary, engineering-quality, and task-state rules.
- [x] Preserve existing dirty worktree state and record the canonical baseline and verification restrictions.
- [x] Identify existing registers and routes so changes extend the current system rather than creating parallel registries.

### 1. Provenance and freshness — complete
- [x] Extend `reusable/baseline/EXTERNAL_SKILL_DEPENDENCIES.md` as the current register for imported skill/reference snapshots; keep historical file-by-file receipts in their existing task records.
- [x] Record the user-provided Apple Xcode reference export, measured file count/bytes, reported-size delta, missing provenance/license data, reference-only authority, and unknown rights/API freshness.
- [x] Record the 166-file external-environment snapshot, six source groups, eight adjacent Apache-2.0 license texts, unknown coverage/upstream revisions, and no-default-copy rule.
- [x] Link the register from `reusable/local-ios-skills/README.md` and state that actual catalog refresh is a separate evidence gate.
- [x] Verify counts, links, and exact registry/README facts; the final manifest and publication are in closeout.

**Acceptance:** one existing authoritative registry is extended, source/rights uncertainty stays explicit, and no duplicate inventory is introduced.

### 2. Skill discovery — static catalog check complete; refresh remains `UNVERIFIED`
- [x] Compare the on-disk skill roots with the skill catalog supplied for this current context. It lists governed top-level skill entrypoints and no separate nested Apple-reference skills.
- [x] Record the filesystem shape: zero nested `SKILL.md` under the three inspected trees, ten `APPLE_SOURCE_REFERENCE.md`, and 83 reference files.
- [x] Record that the current context did not expose a controlled catalog-refresh operation. A fresh catalog reload result therefore remains `UNVERIFIED`; do not claim success from filenames or this prompt alone.
- [x] Record the exact remaining evidence gate: use a supported catalog refresh or new-session reload and confirm no nested `references/apple-source/SKILL.md` entries are exposed.
- [x] Preserve the reference-only layout: current listing and file inventory exposed no nested skill entrypoint to repair; a fresh catalog reload remains an external evidence gate.

**Acceptance:** current observable catalog does not surface nested reference entrypoints; the unperformed refresh and its exact next check remain explicit.

### 3. Safe package verification — complete; execution remains fail-closed
- [x] Inventory the canonical package-vault verifier entrypoints and current-worktree `PackagesForReuse` copies without running any verifier.
- [x] Add a reusable verifier contract to `reusable/sdk-creation/Docs/TESTING_POLICY.md` and exact baseline mirror: scratch ownership, containment/symlink rules, cleanup ownership, resource bounds, and honest status/exit semantics.
- [x] Correct stale SDK README/template guidance that implied verifier cleanup was safe or instructed users to run a disabled placeholder.
- [x] Fail-close six canonical package-vault verifiers found active: five integration helpers that removed pre-existing `.build`/`.swiftpm`, and `AppValidationCore`, whose build/test scratch lifecycle had not been scenario-verified.
- [x] Fail-close the sole active verifier found in the local 45-entry `PackagesForReuse` tree (`AppValidationCore`). Preserve the other pre-existing worktree changes.
- [x] Update the package catalog: 43 canonical entrypoints now comprise 42 explicit disabled stubs and one unavailable stub; the local reusable-package tree has 45 disabled entrypoints.
- [x] Add a package-adoption guard that per-package README/REUSE verification recipes may be historical and require checking the current catalog and exact verifier.
- [x] Run shell syntax checks only on changed stubs and templates; no package verifier, build, or test was executed.
- [x] Keep every verifier disabled/unavailable: restoring execution is outside this documentation plan until a separately authorized success/failure scenario review.

**Acceptance:** no current package verifier executes cleanup/build/tests; skipped/unavailable evidence cannot become PASS. Runtime cleanup behavior remains unverified and disabled.

### 4. Future-project routing and representative scenarios — complete; semantic search ranking remains unmeasured
- [x] Resolve three canonical profiles against `reusable/baseline`; record route-only counts (excluding Level 0) and boundaries in `current-outcome.md`.
- [x] Remove the broad `docs/README.md` library index from the canonical `ios-implementation-refactor` route; the task router assigns that index to documentation-library inventory/operations.
- [x] Add `./PackagesForReuse/PACKAGE_CATALOG.md` to the package-adoption trigger alongside package README references.
- [x] Re-resolve all three canonical profiles after the correction: zero missing, unclassified, unknown-route, or resolver-failure items.
- [x] Record that optional candidates and trigger patterns are upper bounds, not observed reads. Do not transfer one consuming worktree's optional overlay into unrelated projects.
- [x] Review representative new-app, generic implementation, and package-adoption scenarios against selected route membership; each matches its task scope. The resolver emits package trigger patterns but does not expand them or record actual reads. Semantic search ranking remains unmeasured because corpus-ranking evidence is unavailable.

**Acceptance:** selected routes resolve the required documents, expose optional/unresolved inputs honestly, and do not include unrelated app overlays. Search ranking/relevance is not claimed.

### 5. Closeout and publication — complete for the authorized static/documentary scope
- [x] Review the full canonical diff and every changed claim, package verifier path, route consumer, and mirror.
- [x] Run the relevant static documentation checks, exact mirror checks, final `git diff --check`, and canonical manifest freshness. No tests/builds/runtime/UI.
- [x] Commit and push only the canonical Documentation Vault change set. Content commits: `8f070136c5ae79286b590e10aaa3bf9301eee0e0` and `74371060944cf7ac3293ac36f4d32f06e79ec3eb`; exact remote SHA confirmation is part of final closeout.
- [x] Refresh and check only `PackagesForReuse/PACKAGE_SNAPSHOT_MANIFEST.json` after canonical publication; at that stage project-repository changes remained uncommitted. A later explicit user instruction authorizes publishing the accumulated KBN audit change set; see the audit handoff.
- [x] Record both published content commits, corrected route counts, checks, unmeasured evidence, and remaining external `UNVERIFIED` gates in `current-outcome.md` and handoff.

## Evidence and residuals

- Previously published canonical baseline: `f1b0d729b59d782ac4b380a8e892647eeb0f0d3c`.
- Apple references: ten entrypoint folders, 83 files, 941,152 current bytes. The supplied export is reported as 941,232 bytes; there is no raw checksum to reconcile the 80-byte delta. Authorship, rights, source revision, and full API freshness remain UNKNOWN.
- External environment: 166 files in six groups; eight inspected adjacent license texts identify Apache-2.0. Their coverage and source revisions are not established. The prior entrypoint inventory is historical identity evidence only.
- Verifier behavior: canonical package-vault entrypoints are statically disabled/unavailable; shell syntax checks do not establish scenario safety. No verifier was executed.
- Routing: canonical profile results are 11/0/0, 5/0/0, and 4/1/2 (required/optional/triggers); all have zero missing, unclassified, unknown-route, or resolver-failure items. Trigger patterns are not expanded reads. Scenario fit was reviewed; semantic search ranking remains unmeasured.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
