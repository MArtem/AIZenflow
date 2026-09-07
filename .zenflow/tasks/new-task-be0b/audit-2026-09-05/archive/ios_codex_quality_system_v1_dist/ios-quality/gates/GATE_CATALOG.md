# Gate Catalog

## G00 — Task Contract

**Purpose:** prevent implementation against an undefined target.

Pass requires: explicit requested behavior, acceptance criteria, non-goals/constraints, and known ambiguity.

## G01 — Repository / Project Profile

Pass requires: relevant instructions loaded; git state known; relevant target/module/tests inspected; project profile read or absence reported.

## G02 — Risk and Triggers

Pass requires: R0-R5 classification and trigger set with one-sentence rationale.

## G03 — Change Plan

R2+ plan must identify files/layers, state ownership, concurrency/lifetime where applicable, tests, and rollback concerns.

## G04 — Architecture / Invariants

Required for cross-layer/high-risk changes. Pass requires explicit invariants and dependency direction. Broad refactors need ADR/user approval.

## G05 — Consequential Human Approval

Blocks mutation until approval for new/updated dependencies, destructive migration, security weakening, broad public API break, signing/entitlements, deployment/toolchain migration, or other project-defined consequential operations.

## G10 — Unsafe / Forbidden Construct Review

Scan changed lines for risky constructs. Presence is not automatic failure, but each new occurrence must have justification. Unjustified safety escape = FAIL.

## G11 — Compiler / Build

Run the affected build with project scheme/configuration. New warnings are failures under this library even if project does not yet enforce warnings-as-errors, unless pre-existing and clearly identified.

## G12 — Targeted Tests

Run the smallest deterministic test set that proves changed behavior and likely regression paths.

## G13 — Full Relevant Tests

Run full scheme/module test plan for R4+, and R2/R3 when change reach/risk demands it.

## G14 — Concurrency

Pass requires actor/isolation/sendability review, task lifetime/cancellation analysis, and no unjustified unsafe escape. TSan/testing where meaningful.

## G15 — Sanitizer / Runtime Diagnostics

Use appropriate Xcode Test Plan diagnostics for memory/thread/main-thread/C-family UB risks. Runtime issues should be treated as failures for strict plans when project supports it.

## G16 — Memory / Lifetime

Review retain graph for changed escaping closures/tasks/delegates/subscriptions/timers/caches. Use Memory Graph/Instruments when the task is about leaks/lifetime or risk is high.

## G17 — Networking / Auth

Pass requires status/error/cancellation/retry/idempotency/auth/logging review and focused tests for touched paths.

## G18 — Persistence / Migration

Pass requires existing-data analysis. R4 migration requires old-store fixture/real migration test, collision/data-loss strategy, and no delete-on-failure fallback.

## G19 — Security / Privacy

Pass requires applicable OWASP MASVS/Apple controls review, secret/logging check, ATS/permission/privacy-manifest review, and threat-focused verification.

## G20 — Dependency / Supply Chain

Blocks until human approves change. Verify necessity, source/binary, version policy, license, transitive deps, privacy/signature requirements, `Package.resolved` diff, and reproducible CI behavior.

## G21 — Accessibility

For changed UI: semantic labels/actions, Dynamic Type/layout, contrast/non-color cues, motion, focus. Run Accessibility Inspector/manual checks according to risk.

## G22 — Localization

For user-facing text/layout: localized APIs/catalog, plural/formatting, long/RTL considerations, purpose strings when relevant.

## G23 — Performance / Responsiveness

Triggered by hot paths/main-thread work/images/large lists/startup/serialization. Pass from measurement or reasoned evidence appropriate to risk; never claim device performance from code inspection.

## G24 — Background / Lifecycle

Review supported OS mechanism, expiration/cancellation, idempotency/resume, scene/multi-scene semantics, and capabilities.

## G25 — Public API / Module Compatibility

Search call sites/clients, review access level/Sendable contract and compatibility. For reusable Swift packages consider API-breaking diagnostics/symbol graph tools.

## G26 — Build Config / Signing

Any project/xcconfig/entitlements/capabilities/Info.plist privacy/build-setting change needs deliberate diff review; consequential changes require human approval.

## G30 — Final Diff Scope

Line-by-line final diff review. Every changed file intentional; no unrelated cleanup.

## G31 — Secrets / Local Artifacts

No credentials, tokens, machine-specific paths, DerivedData, `.xcresult`, simulator data, debug dumps, or accidental binaries.

## G32 — Sensitive Metadata Diff

Explicitly check `Package.resolved`, `.pbxproj`, workspace, entitlements, privacy manifest, Info.plist, string catalogs, test plans. Unexpected change = FAIL.

## G33 — Verification Report

Generate evidence using `templates/VERIFICATION_REPORT.md`. Unknown/unverified areas must be explicit.

## G34 — Pre-Commit Evidence

Required gates PASS before commit. No “commit now, test later” for production code unless user explicitly requests a draft/WIP workflow.

## G40 — Clean / Reproducible Pre-PR

For R3+: verify from clean enough state to avoid local artifacts masking dependencies. Use resolved package versions and CI-equivalent commands where possible.

## G41 — Release / Rollback

R4/R5: compatibility with older app/backend/store states, rollout/feature flag, rollback and observability strategy.

## G42 — Human Signoff

Human reviews PR/release residual risk. Automated green does not authorize consequential deployment by itself.
