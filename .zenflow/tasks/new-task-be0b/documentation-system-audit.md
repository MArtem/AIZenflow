# Documentation System Audit Receipt

## Scope and authority

Audit date: 2026-09-03. Scope is the canonical Documentation Vault, its governed baseline, the
active AIZenflow project overlay, and the four app documentation boundaries. Historical/archive and
external-environment snapshots were inspected for classification, not treated as active guidance.
No product source, test, build, Simulator, signing, or runtime artifact was changed or run.

## Evidence-backed state

- Documentation Vault sync commit: `2be69b6c946dd0562138da62c6efe36d71eec738`; push to
  `origin/main` was verified with an exact remote SHA match.
- Vault inventory: 3,632 files; four app boundaries; manifest and vault checks pass.
- Active worktree baseline drift after canonical synchronization: 175 exact mirrors, 28 allowed
  overlays, 0 stale/missing/unexpected files, 0 policy failures.
- Active checks pass: docs index (207 paths), task-type router (89 classified docs), consistency,
  boundary, bootstrap contract, documentation remote state, and context-cost check.
- Context cost: Level 0 2,704/5,000 words; dynamic task state 729/3,500; startup total 3,433 words;
  instruction envelope 5,058 words.
  Active task state was compacted from a mixed implementation log; previous detail remains in Git
  history and task archives.
- Relative links in active canonical docs resolve; JSON route/policy files parse successfully.

## Defects found

1. **Figma source parity:** `reusable/agent-prompts/FIGMA_TASK_ROUTER.md` exists in baseline and
   is referenced by routing/manifest claims, but is absent from canonical `reusable/agent-prompts/`.
   Canonical README and deep Figma prompt still use pre-router wording. Promote the verified router,
   align the two canonical prompt files, then regenerate `MANIFEST.md` and `MANIFEST_SUMMARY.md`.
2. **External skill rule conflict:** `reusable/baseline/EXTERNAL_SKILL_DEPENDENCIES.md` says a new
   project must receive the external snapshot, while `NEW_PROJECT_PORTING_GUIDE.md` and
   `TRANSFER_CHECKLIST.md` correctly make snapshots recovery-only. Replace the former with the
   recovery-only, explicit-transfer rule.
3. **Additional source parity:** baseline has newer guardrails absent from canonical sources:
   `GLOBAL_RULES_PORTABLE_SNAPSHOT.md`, `local-ios-skills/ios-code-documentation/SKILL.md`, and
   `sdk-creation/README.md`. Promote the newer content to canonical, then refresh governed mirrors.
4. **Concurrency wording conflict:** active reusable prompt/SDK files still say `@unchecked Sendable`
   is acceptable when justified. The global rule already prohibits `@unchecked Sendable`,
   `nonisolated(unsafe)`, `@preconcurrency`, warning suppressions, and fake `@MainActor`; update
   `feature-generation-master.md`, `code-review-master.md`, and `sdk-creation/Docs/CONCURRENCY_POLICY.md`
   to make that prohibition unambiguous. Educational legacy/external snapshots remain explicitly
   non-authoritative and are not copied into active baselines.
5. **AIFieldbook plan freshness:** `app-intents-discrete-implementation-plan.md` hard-codes an old
   Sol/Tera balanced route and an undefined “M16” static-completion claim. Replace with a reference
   to the current global model router and a named evidence link/status; do not mutate product scope.
6. **Baseline link correctness:** `docs/PACKAGES_AND_MANAGERS.md` used `./PROJECT_HEALTH.md`,
   `./PROJECT_DOCUMENTATION.md`, and `./.codex/...` from inside `docs/`, producing broken links in
   every adopted project. The active overlay now points one directory up; promote the same fix to
   the canonical baseline.
7. **Index clarity:** the active project index called a non-authoritative inventory “Mandatory” and
   omitted the available local-only SwiftUI deep prompt and Figma router. The heading and entries are
   corrected in this worktree; keep canonical/baseline wording explicit about distribution versus
   canonical-only deep references.
8. **Stale source-app links:** the active source-app README referenced removed task rule files. Its
   links now resolve to current handoff/plan and root project rules; no old rules were recreated.
9. **Preserved task-specific rules:** `ios-engineering-rules.md` and
   `services-engineering-rules.md` were important Tchop overlays, not disposable files. Their
   recovery copies are byte-identical across the active retired copy, documentation-split export,
   and canonical legacy/recovery locations. The active saved-prompt inventory and source-app map
   now point to the tracked canonical recovery copies explicitly and state that current work
   follows routed baseline and task state, preventing both information loss and a duplicate active
   authority. SHA-256 matches the pre-deletion Git parent `99e7df83^`; ignored local convenience
   copies are not treated as sources of truth.
10. **Strict concurrency mandate:** canonical bootstrap already carries the user's no-workaround
    policy in `reusable/baseline/AGENTS.md`: no `@unchecked Sendable`, `nonisolated(unsafe)`,
    `@preconcurrency`, warning suppression, or fake/blanket `@MainActor`; active code must use
    actual ownership/isolation boundaries. No duplicate local rule is needed.

## Repairs completed in this worktree

- Synced all 17 stale exact baseline mirrors from the canonical baseline.
- Added `FIGMA_TASK_ROUTER.md` to the active project documentation index.
- Compacted local task `plan.md` and `handoff.md`; preserved historical implementation detail.
- Corrected active project links/index wording and removed duplicate source-app task-state links.
- Corrected saved-prompt rule links to the preserved historical Tchop copies and documented their
  current routed replacements in the source-app map.
- Confirmed the user's strict Swift-concurrency no-workaround mandate is already present in the
  canonical bootstrap baseline; avoided adding a duplicate local rule.

## Canonical synchronization status

The reviewed source and baseline repairs are applied in the canonical vault, manifests are
regenerated, all documentation/boundary/drift checks pass, and the sync commit is pushed with an
exact remote-SHA match. This follow-up receipt update records that result; no archives or user-owned
`AGENTS.md` files were copied, deleted, or modified.
