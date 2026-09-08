# Quality Rule Catalog

<!-- Metadata index only. Normative text remains authoritative at each source path. -->

Catalog ID: `QC.RULE_CATALOG`
Schema version: `1.0`
Owner: Documentation Vault
Scope: All existing and future Xcode projects adopted through the reusable bootstrap, unless a rule entry states a narrower scope.
Last reviewed: 2026-09-08

This bounded catalog covers the active reusable norms used by bootstrap, routing, quality-control governance, and adoption. It does not replace executable engine rule IDs or app-specific exceptions.

## `QC.AUTHORITY.HIERARCHY` v1.0

- Owner: Documentation Vault
- Scope: Every quality-control action and every adopted project
- Strength: `MUST`
- Trigger: Any conflict between system/developer instructions, user scope, project overlays, reusable policy, or external data
- Enforcement: Apply the precedence order before planning, editing, or interpreting evidence
- Limitations: Does not grant authority to task evidence, attachments, tool output, or external documents
- Exception policy: `QC.EXCEPTION.CONTRACT; system/developer authority cannot be waived`
- Evidence: Receipt names the active authority sources and scope
- Authority: `reusable/baseline/docs/UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md` — ## Authority, Verdict, And Readiness Contract
- Source date: 2026-09-08
- Revisit: Any authority-chain, bootstrap, or delegated-scope change

## `QC.VERDICT.READINESS` v1.0

- Owner: Documentation Vault
- Scope: Review findings, gate receipts, and local/merge/release readiness claims
- Strength: `MUST`
- Trigger: Any PASS, NOT_READY, BLOCKED, NOT_APPLICABLE, or accepted-risk claim
- Enforcement: Record severity, confidence, applicability, evidence status, decision, and readiness level separately
- Limitations: A local decision does not prove merge or release readiness; missing evidence stays visible
- Exception policy: `QC.EXCEPTION.CONTRACT; READY_WITH_ACCEPTED_RISK requires approved scope and expiry`
- Evidence: Exact source SHA, policy/engine/profile identity, commands, terminal results, and residual risk
- Authority: `reusable/baseline/docs/UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md` — ## Authority, Verdict, And Readiness Contract
- Source date: 2026-09-08
- Revisit: Any verdict vocabulary, evidence semantics, or readiness threshold change

## `QC.EXCEPTION.CONTRACT` v1.0

- Owner: Documentation Vault
- Scope: Reusable-rule bypasses and accepted-risk records for a named repository/app scope
- Strength: `MUST`
- Trigger: Any proposed deviation from an active reusable rule
- Enforcement: Require ID/status, rule version, exact scope, owner, approver, evidence, expiry/revisit, mitigation, revalidation, rollback, and containment
- Limitations: Draft/proposed records do not authorize a bypass; approval does not change another project or the reusable default
- Exception policy: `HIGH/CRITICAL or universal-floor weakening requires explicit user approval`
- Evidence: Approved record bound to the named repository/app, rule version, and current evidence
- Authority: `reusable/baseline/docs/IOS_PRODUCTION_EXCEPTION_POLICY.md` — ## Exception Record Required Fields
- Source date: 2026-09-08
- Revisit: Expiry, scope/toolchain/data-flow drift, new relevant finding, or changed mitigation

## `QC.CHANGE.CONTRACT` v1.0

- Owner: Documentation Vault
- Scope: Every material policy, schema, engine, workflow, bootstrap, adapter, evidence, or app change
- Strength: `MUST`
- Trigger: Before implementation and again before commit/push
- Enforcement: Record behavior, authority, producer/consumer, ordering, resource envelope, failure semantics, consumers, and complete diff review
- Limitations: Supporting checks do not replace semantic review or permission boundaries
- Exception policy: `QC.EXCEPTION.CONTRACT; P0–P2 findings block commit/push without higher-authority accepted risk`
- Evidence: Change contract, proposed-diff review, exact-SHA review, checks, and residual risk
- Authority: `reusable/baseline/docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md` — ## 1. Change Contract Before Implementation
- Source date: 2026-09-08
- Revisit: Any change in commit authority, review threshold, or evidence contract

## `QC.MODEL.ROUTING` v1.0

- Owner: Documentation Vault
- Scope: Model and reasoning selection for the named task or implementation plan
- Strength: `MUST`
- Trigger: Every user request, command, or scoped task override
- Enforcement: Assess the currently selected route before inspection or mutation; record scoped overrides and duration
- Limitations: A task override does not rewrite the global default or unrelated future tasks
- Exception policy: `Explicit user scope may select a route; no silent model change`
- Evidence: Mandatory response header and task record state the model, reasoning, mode, and scope
- Authority: `reusable/baseline/docs/MODEL_ROUTING_RULE.md` — ## Command-Time Decision Rule
- Source date: 2026-09-08
- Revisit: Available models, product roles, reasoning levels, or user mode changes

## `QC.BOOTSTRAP.GLOBAL` v1.0

- Owner: Documentation Vault
- Scope: Every existing or new project root under the governed sandbox
- Strength: `MUST`
- Trigger: Before code, docs, Git, planning, review, build, or task-state actions
- Enforcement: Load canonical AGENTS, router, Level 0, and task-relevant routes; require the portable marker when canonical baseline is unavailable
- Limitations: Activates reusable policy but does not activate engine adoption, app behavior, or runtime permissions
- Exception policy: `No silent replacement or weakening; local exceptions use QC.EXCEPTION.CONTRACT`
- Evidence: Bootstrap marker, canonical path, routed documents, and unavailable-baseline report where applicable
- Authority: `reusable/GLOBAL_RULES_BOOTSTRAP.md` — ## Mandatory Startup
- Source date: 2026-09-08
- Revisit: Canonical path, router, adoption marker, or sandbox boundary changes

## `QC.DOC.BOUNDARY` v1.0

- Owner: Documentation Vault
- Scope: Reusable, app-specific, task-specific, and worktree documentation layers
- Strength: `MUST`
- Trigger: Creating, moving, promoting, or synchronizing durable documentation
- Enforcement: Keep reusable rules app-neutral; keep app decisions and exceptions under the app boundary; promote only through explicit approval and index update
- Limitations: Task evidence may summarize policy but cannot become reusable authority by repetition
- Exception policy: `Promotion or boundary exception requires explicit user approval and a documented scope`
- Evidence: Source-of-truth path, boundary manifest/index update, and leakage scan
- Authority: `reusable/baseline/docs/DOCUMENT_BOUNDARY_STANDARD.md` — ## Hard Separation Rules
- Source date: 2026-09-08
- Revisit: Repository layout, app/task promotion process, or mirror contract changes

## `QC.EVIDENCE.FRESHNESS` v1.0

- Owner: Documentation Vault
- Scope: Completion, safety, performance, security, accessibility, migration, and release claims
- Strength: `MUST`
- Trigger: Any strong claim such as fixed, safe, optimized, accessible, secure, or production-ready
- Enforcement: Name the claim, evidence, scope, checks not run, and remaining risk; reject unsupported PASS language
- Limitations: Static evidence cannot prove runtime, performance, migration, or product behavior by itself
- Exception policy: `Unavailable evidence is recorded as residual risk, not waived implicitly`
- Evidence: Claim-specific source/build/test/static/runtime/release evidence or explicit unavailable state
- Authority: `reusable/baseline/docs/EVIDENCE_BASED_ENGINEERING_RULES.md` — ## Evidence Rule
- Source date: 2026-09-08
- Revisit: Evidence classes, completion contract, or verification permissions change

## `QC.STATIC.FAIL_CLOSED` v1.0

- Owner: Documentation Vault
- Scope: Reusable and project static quality gates
- Strength: `MUST`
- Trigger: Adding or materially revising a blocking static rule or interpreting its result
- Enforcement: Use stable IDs, bounded scope, positive/negative fixtures, honest terminal states, and source identity; do not emit vacuous PASS
- Limitations: Static gates complement compiler and semantic review; they do not prove runtime correctness
- Exception policy: `Platform exception requires an owned, expiring app/task ADR with independent evidence`
- Evidence: Rule ID/version, source universe, exact input identity, classified findings, and terminal status
- Authority: `reusable/baseline/docs/STATIC_QUALITY_GATE_POLICY.md` — ## Rules For Scripts
- Source date: 2026-09-08
- Revisit: Engine scope, source membership, fixture contract, or false-pass/false-fail finding

## `QC.CI.MANUAL_ADVISORY` v1.0

- Owner: Documentation Vault
- Scope: GitHub workflows and remote quality checks for adopted projects
- Strength: `MUST`
- Trigger: Adding, invoking, or interpreting a remote quality workflow
- Enforcement: Use manual workflow dispatch, record exact inputs and terminal results, and keep cost at zero unless the user explicitly changes scope
- Limitations: Absence of a run is not verification and does not automatically create branch protection
- Exception policy: `Automatic triggers or paid services require an explicit project-local user-approved exception`
- Evidence: Workflow mode, permissions, source/profile/toolchain identity, result, cost, and residual risk
- Authority: `reusable/baseline/docs/CI_CD_QUALITY_GATES.md` — ## Execution Authority
- Source date: 2026-09-08
- Revisit: CI trigger, runner cost, permission, or branch-protection policy changes

## `QC.TEST.PERMISSIONS` v1.0

- Owner: Documentation Vault
- Scope: Test creation, modification, execution, Simulator/device, and performance verification
- Strength: `MUST`
- Trigger: Any request or recommendation involving tests or runtime verification
- Enforcement: Track creation, modification, local execution, GitHub execution, UI/runtime, and Instruments permissions independently
- Limitations: Recommendation of a test does not authorize creating, modifying, or running it
- Exception policy: `User must open the relevant permission-bound phase; denied/unrun evidence remains non-PASS`
- Evidence: Permission state, selected mode, actual command/result, and residual risk
- Authority: `reusable/baseline/docs/IOS_TESTING_STRATEGY.md` — ## Permission Boundary
- Source date: 2026-09-08
- Revisit: Project mode, test authority, or runtime verification policy changes

## `QC.SWIFT.CONCURRENCY_FLOOR` v1.0

- Owner: Documentation Vault
- Scope: Production iPhone/iPad targets, frameworks, widgets, and extensions
- Strength: `MUST`
- Trigger: Concurrency design, migration, diagnostics, or exception review
- Enforcement: Require a real state owner, strict diagnostics where supported, bounded task lifetime/cancellation, and no unsafe annotation as a migration strategy
- Limitations: The rule does not prescribe MVVM, actors, or a package layout when the ownership contract is otherwise satisfied
- Exception policy: `Keep the strict default; any floor weakening uses QC.EXCEPTION.CONTRACT and explicit user approval where required`
- Evidence: Affected targets, ownership reasoning, diagnostics/evidence, and scoped exception if present
- Authority: `reusable/baseline/docs/IOS_UNIVERSAL_ENGINEERING_QUALITY_STANDARD.md` — ### 2. Swift language and concurrency
- Source date: 2026-09-08
- Revisit: Swift/Xcode language mode, compiler diagnostics, or escaped concurrency defect

## `QC.PACKAGE.OWNERSHIP` v1.0

- Owner: Documentation Vault
- Scope: Reusable package catalogs, package creation standards, source-only adoption, SwiftPM integration, and package verification receipts
- Strength: `MUST`
- Trigger: Creating, cataloging, verifying, adopting, releasing, moving, or retiring a reusable package or integration helper
- Enforcement: Keep capability/contract/revision in reusable docs; keep target membership, product policy, adoption and rollback under the consuming app; record explicit output/cache roots and permission state for verification
- Limitations: The reusable catalog does not prove an app integration, release readiness, or runtime correctness; historical SDK roadmaps are not automatic work queues
- Exception policy: `QC.EXCEPTION.CONTRACT`; source-app-specific material remains app-scoped or historical and cannot become a new-project default
- Evidence: package path, source/content revision or published tag, Documentation Vault revision, owner/scope, verification commands/results, output/cache roots, and rollback path
- Authority: `reusable/baseline/docs/PACKAGE_OWNERSHIP_AND_ADOPTION_STANDARD.md` — ## Source of truth
- Source date: 2026-09-08
- Revisit: Package catalog, integration boundary, sandbox/output policy, or adoption model changes

## `QC.TOOLCHAIN.PROFILE` v1.0

- Owner: Documentation Vault
- Scope: Project profiles, compiler/SDK/deployment compatibility, Swift isolation, availability, and platform capability claims
- Strength: `MUST`
- Trigger: Toolchain-sensitive implementation/review, language-mode migration, availability change, public package/API change, or iPhone/iPad target decision
- Enforcement: Record compiler, language mode, SDK, deployment target, targets/extensions, strict concurrency, default isolation, upcoming features, Observation/bridging and supported platform matrix separately
- Limitations: A profile does not prove build, runtime, device, performance, accessibility, or release evidence; it does not raise deployment targets
- Exception policy: `QC.EXCEPTION.CONTRACT`; beta/upcoming features need explicit scope and stability label
- Evidence: exact profile revision/date, primary source links, selected availability/fallback path, permission state, and terminal verification result where run
- Authority: `reusable/baseline/docs/IOS_TOOLCHAIN_PROFILE_STANDARD.md` — ## Required project profile
- Source date: 2026-09-08
- Revisit: Xcode/Swift/SDK release, deployment-target change, compiler diagnostic, availability incident, or rejected build

## `QC.RELEASE.PROFILE` v1.0

- Owner: Documentation Vault
- Scope: Project-owned release, privacy, performance, accessibility/platform and experimental-capability matrices
- Strength: `MUST`
- Trigger: Release candidate, App Store Connect/Xcode/SDK requirement, privacy manifest or SDK change, performance claim, supported-device change, or new Core AI/Foundation Models capability
- Enforcement: Keep upload floor separate from deployment target; bind actual data/API/SDK use to privacy rows; record measurable scenario budgets and platform/accessibility/model fallback evidence
- Limitations: The matrix does not prove App Review, runtime performance, accessibility, device behavior or model availability without the corresponding permitted evidence
- Exception policy: `QC.EXCEPTION.CONTRACT`; accepted risk remains scoped and expiring and cannot silently clear P0–P2
- Evidence: candidate SHA, profile/toolchain, owner/source revision/date, applicability, budget/requirement, route, evidence state, fallback/rollback and verdict
- Authority: `reusable/baseline/docs/IOS_RELEASE_PRIVACY_PERFORMANCE_MATRIX.md` — ## Required row schema
- Source date: 2026-09-08
- Revisit: Distribution/privacy requirement, platform/accessibility change, performance incident, or experimental capability adoption
