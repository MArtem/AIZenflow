# Current Plan

## Goal
Remediate every currently actionable finding from the full AI Fieldbook audit while preserving the approved local-only Iteration 1 product contract and leaving build, tests, Simulator, device, and Instruments verification for a separately authorized validation phase.

## Active Checklist
- [x] Make staged deletion crash-recoverable and propagate rollback/finalization failures honestly.
- [x] Fix modal mutation refresh, URL workspace editing, deep-link type validation, and bounded detail-state invalidation.
- [x] Harden URL/file input validation, file protection, new-import integrity metadata, and startup persistence diagnostics.
- [x] Move export preparation and large audio preparation away from the main actor; add cancellation and resource cleanup.
- [x] Add audio-session interruption, route-change, retry, and draft-cleanup lifecycle handling.
- [x] Bound unfiltered search work and add LRU detail-cache eviction, memory-pressure cleanup, and media-resource release.
- [x] Add a valid privacy manifest and privacy-safe local diagnostics without adding analytics or cloud reporting.
- [x] Expand Russian localization coverage/pluralization and improve accessible error/progress behavior where code evidence allows.
- [x] Reconcile the AI Fieldbook product, architecture, implementation, acceptance-gate, and lab-plan documentation with the implemented Iteration 1 state.
- [x] Run allowed Swift 6 type-check, static quality, plist/privacy-manifest, localization, documentation, secret, and diff checks.
- [x] Update the task handoff with completed scope, evidence, deferred build/runtime gates, and remaining external requirements.

## Deliberately Deferred Evidence And External Decisions
- [ ] Run Xcode build, Simulator/physical-device QA, crash-injection recovery, Instruments, Privacy Report, archive/signing, and dSYM validation after explicit authorization.
- [ ] Decide whether to add full-text indexing for large text/tag corpora; current database-side filters and result limits improve bounded cases but are not an FTS replacement.
- [ ] Decide whether to migrate legacy imported filenames to hashes and explicitly migrate/protect existing SwiftData store files; new imports are integrity-checked and app-owned content files use complete protection.
- [ ] Select a crash-reporting/CI provider and signing team before adding remote observability or release automation; no analytics or third-party telemetry was guessed.

## Verification Policy
- Allowed now: read-only inspection, compiler-independent static scripts, plist validation, documentation validators, secret scan, and `git diff --check`.
- Not allowed without a separate user authorization: writing/modifying tests, Xcode build, test execution, Simulator UI, physical-device QA, crash injection, Instruments, archive/signing, or App Store upload validation.

## Preserved Product Boundaries
- Iteration 1 remains local-only with no backend, analytics, cloud processing, App Intents, or AI runtime.
- No destructive migration or automatic store reset is permitted.
- Iteration 2 remains blocked until manual acceptance gate 1.26 is completed and accepted.
- No commit or push is authorized for this project repository.

## Context Transfer Rule
**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
