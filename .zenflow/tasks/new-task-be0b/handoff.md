# Current Task Handoff

## Orientation

- Worktree/task: `/Users/Artem/.zenflow/worktrees/new-task-be0b`, `new-task-be0b`.
- Mode: `эконом`; execution model: `GPT-5.6 luna`, xhigh, with no later switch.
- Scope: universal governed quality system for current/future Git repositories containing Xcode iOS
  projects. Documentation owns policy; QualityControl owns execution; apps own facts/permissions.
- Required transfer: **перечитать весь актуальный набор документации и правил для этого worktree и
  task-контекста**. After Level 0, load only this plan/handoff and the active task route.
- Completed temporary detour: audited all authoritative tracked iOS/Xcode project copies and set
  maximum `SWIFT_STRICT_CONCURRENCY = complete`, then performed authorized build/install/launch
  verification. The user explicitly kept the current Luna xhigh route; PR creation/merges and
  manual `workflow_dispatch` remain user-operated. Continue with the main plan after the user
  starts the next PR phase.

## Evidence-backed completed state

- Documentation governance was published before this task; do not restart Phase 0/1.
- Canonical reusable snapshot fixes are now published in Documentation Vault at commit
  `d333cf547f3980fff91ce5d9ec7b828a1d36a282`; `origin/main` resolves to that exact SHA.
- Engine repo `/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl` is on
  `codex/stage9d-static-evidence-execution`, final HEAD
  `9f3f3676b56e41e56bc30cd9c6d155738df32f6a`, trusted base
  `4100c2103ba2a39c82bd782787bde4fefe501acd`. Full warnings-as-errors suite: 162 tests, 16 suites,
  0 failures. `AGENTS.md` remains the sole pre-existing dirty user file and was never staged.
- Canary repo `/Users/Artem/.zenflow/worktrees/canary-global-rules` is on
  `codex/global-rules-bootstrap-canary`, final HEAD
  `388e885614f3ff6f5433599f3e4bb872ea2cfa27`, trusted base
  `af85bef43a6981832459651fadfa021fe69458f7`. Profile/workflow pin engine SHA
  `9f3f3676b56e41e56bc30cd9c6d155738df32f6a` exactly five times; JSON/pbxproj/scheme/YAML/diff
  checks and both deterministic adapters passed; worktree is clean.
- Fresh final engine/source detached worktrees and task-local caches were used. The latest recorded
  release `quality` binary CDHash is `01f86a1d3a963dc99115fc51b2648d943a14e948`, bound to the
  pre-adapter engine SHA `c4470e513771a73daae42383e78f6540ae7d433f`; the adapter commit changes no
  Swift executable source, and a new binary/CDHash for `9f3f3676b56e41e56bc30cd9c6d155738df32f6a`
  is intentionally not claimed. Earlier mode-execute/bootstrap
  binaries are historical and obsolete after later commits.
- Deterministic `quality mode-plan --mode <static|build|build-and-tests|full>` is available, and
  `quality mode-execute` now sequences authenticated static/build boundaries. Child evidence is
  preserved per step; no composite evidence is inferred. Test/UI/archive/signing/feature-flag/
  privacy execution remains explicit `NOT_RUN_BY_USER_DECISION`, `NOT_APPLICABLE`, or `BLOCKED`.
- Read-only bootstrap inventory foundation is committed in engine: `bootstrap/inventory.py`,
  `bootstrap/plan.schema.json`, and the bootstrap README. It supports deterministic `inventory` and
  `dry-run`, exact/overlay/conflict/symlink/traversal classification, bounded closed plans, and
  idempotent reports. Explicit apply/post-check/rollback are implemented in the engine, but no app
  repository has been applied or modified.
- Bootstrap receipts: `runtime/bootstrap-inventory.json` and `runtime/bootstrap-dry-run.json` prove
  missing exact source plus conflict classification; `runtime/bootstrap-invalid-report-1.json` and
  `runtime/bootstrap-invalid-report-2.json` are byte-identical `BLOCKED` traversal reports.
- Positive public boundary report:
  `.zenflow/tasks/new-task-be0b/runtime/mode-plan-proof/positive-report.json` — exit 0,
  top-level/report `PASS`, `QC.BUILD=PASS`, non-null evidence, verification `READY`, zero issues;
  exact source SHA `049647fe…`, engine SHA `bcc38a58…`, CDHash, tracked profile hash, toolchain
  (Xcode 26.6 / Swift 6.3.3), action, command hash, and artifact hashes are bound.
- Negative public boundary report:
  `.zenflow/tasks/new-task-be0b/runtime/mode-plan-proof/negative-report.json` — disposable
  clone SHA `6355fc437cc4452ccdd5fe3cee51896a939f2d5c`, deliberate Swift type error, exit 1,
  top-level/report `FAIL`, evidence absent, stable `QC.BUILD_EVIDENCE.BUILD_FAILED`, negative clone
  clean after execution. Official canary stayed untouched.
- Evidence aggregation is now implemented in `EvidenceVerifier.aggregate` and exposed through
  `quality aggregate-evidence`: bounded input count, strict receipt/expectation loaders,
  authenticated shared identity, conservative deduplication/ordering, and explicit empty/limit/
  mismatch rejection. Focused evidence suite: 41 tests; full engine suite: 162 tests in 16 suites,
  no failures. The initial mode runner, reversible bootstrap lifecycle, and deterministic catalog
  are now present; the first executable catalog adapter (`QC.SECRETS.TRACKED`) is committed with
  positive/negative fixtures and a bounded result schema. Remaining staged adapters remain pending.
- Reversible bootstrap proof: `runtime/bootstrap-apply-proof/receipt.json` records dry-run,
  authorization denial, authorized apply, post-check, changed-target rollback preservation, and
  authorized rollback PASS paths. The apply journal is bounded and plan-hash bound.
- Deterministic catalog proof: `runtime/catalog-proof/receipt.json` records historical JSON/
  closed-shape/unique-ID validation for 18 canonical checks and the pre-adapter engine compile.
- Canary repin proof: `runtime/canary-repin-proof/receipt.json` records the historical engine pin;
  the current adapter-aware pin is recorded separately below.
- Mode execution proof: `runtime/mode-execution-proof/receipt.json` records the pre-adapter engine
  SHA/CDHash, warnings-as-errors release compile, full 162-test/16-suite PASS, bounded
  invalid-argument smoke, and omitted app runtime/capability checks.
- Adapter-aware canary repin proof: `runtime/canary-adapter-repin-proof/receipt.json` records the
  exact engine/canary SHAs, five-reference pin, contract checks, both adapter invocations, adapter
  PASS, and omitted runtime workflow/build execution.
- TODO adapter proof: `runtime/todo-adapter-proof/receipt.json` records the positive/negative
  fixtures and false-positive regression for `QC.TODO.OWNER` after narrowing markers to comments.
- Deterministic adapter proof: `runtime/secret-adapter-proof/receipt.json` records AST/JSON/catalog
  checks plus positive canary, positive fixture, and deliberate-negative fixture results for
  `QC.SECRETS.TRACKED`; no app runtime or GitHub workflow was run.
- TODO adapter proof: `runtime/todo-adapter-proof/receipt.json` records the positive/negative
  fixtures and false-positive regression for `QC.TODO.OWNER` after narrowing markers to comments.
- Pre-PR contract audit: `runtime/pre-pr-contract-audit/receipt.json` confirms the canonical reusable
  template already encodes user authorization, full-range Exhaustive review, repeat-after-fix,
  exact-HEAD receipts, and no automatic external Codex Review.
- Applicability/release audit: `runtime/applicability-release-audit/receipt.json` confirms profile-v2
  requires explicit records for all eight capabilities and the release checklist covers signing,
  privacy, runtime, diagnostics, rollout, rollback, and residual-risk semantics.
- Format/lint decision: `runtime/format-lint-decision/receipt.json` records why SwiftLint/SwiftFormat
  remain staged until immutable versions, bounded adapters, and fixtures are reviewed.
- Workflow governance audit: `runtime/workflow-governance-audit/receipt.json` confirms manual-only,
  least-privilege, action-pinned, bounded-time, no-paid-AI workflow semantics and adapter ordering.
- Pilot discovery: `runtime/pilot-discovery/receipt.json` identifies clean `MVVMExample` and Tchop
  multi-target candidates. `runtime/pilot-bootstrap-boundary/receipt.json` records the read-only
  inventory/dry-run boundary and preserves both existing overlays.
- Pilot consumer apply: MVVMExample now has a schema-v2 `.quality-control/profile.json` and a
  manual-only static workflow; Tchop has the corresponding profile and new manual-only workflow.
  Both pin engine `9f3f3676b56e41e56bc30cd9c6d155738df32f6a`. Snapshot false positives were fixed
  without changing the engine: MVVM HEAD is `b692a47718ce3a231bff091f40668eb647f8ebc9`, Tchop
  HEAD is `a9fcafb4589bd4530170fd3cd74bc1c8f8b13ef0`, and both remotes point to those exact commits.
  Baseline PRs #7 and #16 targeted `main` and are now merged.
- MVVM workflow run #21 then failed at the tracked-secret step because the workflow checked out the
  engine inside the consumer root, making the checkout appear unclean. The bounded workflow-only
  fix was published in MVVMExample PR #9 (`8027224`) and Tchop PR #17 (`92cd7a12`); both were then
  merged. MVVM PR #8 was merged before the final path correction and is superseded.
- The next manual runs instead exposed the schema-v2 Xcode graph boundary in both pilots: the
  ordinary `static` command correctly returned `BLOCKED` because no authenticated target-membership
  evidence exists in that workflow. Canonical engine commit `9ac4cca4647cbd229a99250a4b60cd5ce27cca8c`
  adds the explicitly requested `--scope explicit-source-paths` mode. The strict default and
  `static-evidence` path are unchanged; scoped PASS explicitly does not assert Xcode membership.
  Engine PR #20, MVVMExample PR #10 (`3676c0b0561bee45fd186cde441996980b02376f`), and Tchop PR #18
  (`0a2403e5156e8b2a2b35bbae675473a1bd224302`) were opened for this sequence. The resulting merge
  and manual-run status is recorded below.
- Engine #20 and pilot PRs #10/#18 are now merged. GitHub run inspection confirms both post-merge
  manual workflows green. Record this only as scoped static workflow PASS: it does not assert
  Xcode target membership, app build/tests/runtime, or release readiness. Remaining implementation
  route is the staged deterministic-adapter backlog, with test-writing reopened explicitly per adapter.
- `QC.GENERATED.OWNERSHIP` is implemented and published in canonical engine PR #21 at exact
  head `05c9f7dc7f833e3ec9095000ab8f5ea16460b5f0`; the merge commit is
  `cd6f575a99e606496651292e6ee8d43c6c22f8c9`. It requires tracked
  `.quality-control/generated-files.json`, matching SHA-256/generator/version/marker facts, and
  returns `BLOCKED` for unsafe or unsupported inputs. Python contracts (7), positive/negative
  fixtures, manifest/result schemas, and the unchanged Swift suite (164 tests in 16 suites) pass.
  Consumer adoption is now prepared in MVVMExample PR #11, AIZenflow PR #19, and canary PR #3;
  each pins the merged engine, tracks an explicit empty manifest (no current markers), and runs
  the gate before static/build checks. All three are merged and manually green: MVVMExample run
  `33446612608` (#25), AIZenflow run `33446639198` (#4), and canary run `33446683945` (#4); each
  has a successful `Run generated ownership check` step. Canary build was skipped because static
  mode was selected.
- Pilot consumer checks: profile JSON/path invariants, workflow YAML parsing, manual-only trigger
  inspection, exact engine-pin checks, `git diff --check`, deterministic tracked-secret/TODO
  checks, and the MVVM local static gate passed for both pilots where applicable. Local
  `swift run quality validate-profile` was attempted but blocked by the host sandbox because
  SwiftPM manifest compilation tried to access `/Users/Artem/Library` and `/Users/Artem/.cache`;
  no app build, test, or Simulator execution was performed. GitHub manual workflows are now
  independently verified green after merge; run IDs and successful generated-ownership steps are
  recorded in `runtime/generated-ownership-adoption/receipt.json`.

## Completed temporary detour — maximum Swift strict-concurrency audit

- Audited all 80 tracked real `.xcodeproj/project.pbxproj` files across 13 authoritative Git
  worktrees. The physical inventory also contained 33 non-tracked/generated or retired copies and
  3 fixture containers without `project.pbxproj`; these were excluded from mutation and commits.
- All 644 discovered `buildSettings` blocks now contain `SWIFT_STRICT_CONCURRENCY = complete`; no
  tracked project retains `targeted`. Swift 5 builds therefore use the maximum explicit mode;
  Swift 6 projects already have complete language-mode semantics and retain the setting for parity.
- Final matrix is 80/80 PASS for task-local Debug build, install, and launch; Canary's macOS
  executable also ran. Evidence is in `runtime/concurrency-audit/max-complete/`.
- Tests were not run or modified. The only source compatibility fixes were the proven iOS 26
  availability boundaries in five historical AIFieldbook clones. PanModal's existing iOS 10
  deployment-target warning remains documented and unchanged.
- All 13 logical commits were reviewed, committed, pushed to same-named branches, and verified for
  remote SHA parity. Full receipt: `runtime/concurrency-audit/max-complete/receipt.json`.

## Active continuation

## Completed temporary detour — Swift 6 language-mode migration (2026-09-02–03)

- User-approved scope: migrate all 80 authoritative tracked Xcode projects to `SWIFT_VERSION = 6.0`,
  keep `SWIFT_STRICT_CONCURRENCY = complete`, build/install/launch with task-local artifacts,
  repair only real diagnostics using architectural actor/sendability ownership, and clean only
  task-created DerivedData. Tests remain out of scope. Commit/push/PR authority is not implied.
- Current model/override: `GPT-5.6 luna`, xhigh, `эконом`; user explicitly requires no hacks,
  warning suppressions, `@unchecked Sendable`, `nonisolated(unsafe)`, `@preconcurrency`, or fake
  `@MainActor` boundaries. A Sol route is normally recommended, but the user explicitly permits
  this constrained execution on the current Luna route.
- Project-setting inventory/mutation is complete but uncommitted: all 80 authoritative project
  files now declare `SWIFT_VERSION = 6.0` and `SWIFT_STRICT_CONCURRENCY = complete`; `swift5=0`.
  Preserve user-owned dirty `AGENTS.md` files and do not stage anything yet.
- Swift 6 runner root: `.zenflow/tasks/new-task-be0b/runtime/concurrency-audit/swift6/`; runner:
  `runtime/concurrency-audit/max-complete/run-authoritative-matrix.sh`. It deletes only its own
  per-project DerivedData before each build and after success. Existing failure DerivedData must
  be removed only after evidence is recorded/final verification passes.
- All 80 authoritative tracked Xcode projects now declare `SWIFT_VERSION = 6.0` and
  `SWIFT_STRICT_CONCURRENCY = complete`.
- Canonical architecture cases 01–14, three MVVMExample worktrees (45 projects), three new-task
  app projects, five AIZenflow/Tchop app worktrees (15 projects), two canary projects, and PanModal
  all passed clean Swift 6 build/install/launch verification. Logs are under
  `.zenflow/tasks/new-task-be0b/runtime/concurrency-audit/swift6/`.
- Production Swift sources across all authoritative worktrees contain no
  `@unchecked Sendable`, `nonisolated(unsafe)`, or `@preconcurrency`. Real boundaries are actors,
  immutable Sendable values, async storage contracts, and explicit main-actor UI ownership.
- Tests were not modified or run. Remaining prohibited markers, if any, are confined to existing
  test fixtures or verifier-script text and are intentionally outside this migration scope.
- Commits, pushes, and PRs remain pending explicit authorization. Return to the saved Universal
  iOS/Xcode Quality-Control plan.

- `QC.DEPENDENCY.LOCK_DRIFT` is implemented and published as engine PR #22:
  https://github.com/MArtem/AIZenflowQualityControl/pull/22. Exact head is
  `0972bf2033e432952fb7eed2583266ea96aeb660`; trusted base is
  `cd6f575a99e606496651292e6ee8d43c6c22f8c9`. The test-writing phase was explicitly opened;
  18 Python tests and positive/negative fixtures pass. The engine is now merged as
  `2757d4ad9626275d3cc4be4f8815b64e72c625c9`; MVVMExample #12, AIZenflow/Tchop #20, and
  QualityControlCanary #4 are wired, merged, and user-reported green after manual workflow_dispatch runs.
  Do not reinterpret these deterministic results as app build/test/release evidence.
- `QC.LOCALIZATION.CATALOG` is implemented and merged in engine PR #23:
  https://github.com/MArtem/AIZenflowQualityControl/pull/23. Engine merge commit is
  `096e0d0998efafaedf3ff34c2c180885bd8d2e7f` (feature head `2305108f052c52071a233753dbfd05058b048472`).
  The adapter reads clean exact Git `HEAD`, validates tracked `.strings`, `.stringsdict`, and
  `.xcstrings` resources within immutable limits, returns `BLOCKED` for malformed/duplicate/
  unsupported input, and returns `FAIL` for key drift or missing/empty fallback coverage.
  Test-writing was explicitly opened: 32 Python tests and fixture smoke pass. Consumer adoption PRs
  are open: MVVMExample #13 (`1c964d4`), AIZenflow/Tchop #21 (`2af57fab`), and QualityControlCanary
  #5 (`b0f4781`). User-reported manual workflow_dispatch results are PASS for MVVMExample and
  canary, while Tchop returns the expected FAIL with six findings because its tracked German
  catalog is an intentionally partial rollout. Receipt: `runtime/localization-adapter/receipt.json`.
- `QC.RESOURCES.ASSETS` is implemented locally in engine commit
  `46bb0cda22e4f8776dd4303eacbc846a6befe0db`, based on trusted base
  `2305108f052c52071a233753dbfd05058b048472`. The adapter reads clean exact Git `HEAD`, validates
  bounded Xcode `.xcassets` metadata and known asset-set ownership, rejects malformed/duplicate/
  unsupported/oversized/traversal/symlink inputs as `BLOCKED`, and reports missing/duplicate/orphan
  resources, forbidden compiled outputs, and missing high-confidence literal references as `FAIL`.
  No-resource repositories are `PASS`; dynamic names, target/bundle membership, visual validity,
  and app runtime behavior remain outside the claim. Test-writing was explicitly opened: 13 focused
  Python tests, the full 45-test Python suite, positive/negative fixture smoke, and local smoke for
  MVVMExample, Tchop, and QualityControlCanary pass. Swift package evidence is reused because Swift
  sources are unchanged. Engine PR #24 is merged as
  `6ebf4b6e41e501fb630da386cc5490bf1495d580`. Consumer adoption is merged in MVVMExample #14,
  AIZenflow/Tchop #22, and QualityControlCanary #6; all three pin that merge SHA and add the
  manual-only resource gate. Receipt: `runtime/resources-assets-adapter/receipt.json`. User-run
  workflow results are now recorded: MVVMExample #28 (`33653619069`) PASS with resources PASS,
  Canary #7 (`33653665358`) PASS with resources PASS and static-only build skipped, and Tchop #7
  (`33653647456`) FAIL at the existing localization catalog gate, so resources was skipped by
  fail-fast ordering. The concrete Tchop findings are eight missing German accessibility/login
  keys plus `app.localization.languageName` missing from English and Russian catalogs, mirrored
  in both `PackagesForReuse` and `PackagesInUse`; no fix or exception has been applied.
- Do not run external Codex Review automatically; the user may invoke it separately. Do not run app
  builds/tests/Simulator or alter app source in this continuation without explicit permission.
- Current authority override: the user performs PR merges and manual GitHub Actions
  `workflow_dispatch` runs. The agent must announce when either is needed and then inspect the
  resulting workflow evidence; it must not merge or dispatch on the user's behalf.

## Guardrails and next route

- No branch protection, external Codex Review, archive/signing/release, or unrelated app
  build/test is authorized for the main continuation. The user authorized this bounded concurrency
  build/run detour and the resulting source/config commits. The user performs all PR creation,
  merges, and manual workflow dispatch. Within this plan, engine,
  canary, and these pilot commits/pushes are authorized; future app-repository pushes remain
  bounded to separately authorized pilots.
- Existing permission covers engine package compile/tests and current public canary build proofs.
- Phase G audit confirms profile-v2, identity binding, fail-closed fixtures, app-neutral defaults,
  bounded evidence aggregation, and the initial manual-mode runner. Bootstrap lifecycle is now
  reversible and the deterministic catalog is published; `QC.RESOURCES.ASSETS` is implemented and
  merged, with consumer adoption PRs #14/#22/#6 merged and their user-run workflow results recorded;
  the next
  implementation block is continuing executable adapters/fixtures for
  the remaining staged checks (including the SwiftLint/SwiftFormat decision),
  followed by Phase I feature-flag/release-safety applicability work; the pre-PR contract itself is
  already canonical and audited, then Phase J pilots/publication/rollout. Do not mark an item complete without
  evidence.
- Task-created disposable clone, diagnostic worktrees/binaries, stale reports/caches, and final build
  cache remain governed by the task boundary; proof receipts remain under runtime. Do not touch
  repositories or user files outside the explicitly listed audit scope.
- `BLOCKED` is never PASS. Fix P0–P2 before promotion; fix or report P3. Keep all artifacts under
  `/Users/Artem/.zenflow`.
