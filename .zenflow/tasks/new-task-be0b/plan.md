# Current Plan

## Goal
Preserve local-only Iteration 1 and unlock only user-approved, Simulator-verifiable Iteration 2 labs after gate `1.26-S`. Device, iOS 27, backend, and cloud capabilities remain tutorial-only until their gates open.

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
- [x] Split the Iteration 1/2 roadmap into Simulator-first and physical-device stages without authorizing device-dependent code.
- [x] Record clarification, alternatives, and `sol`/`tera`/`luna` model-plus-reasoning routing; expand canonical iOS knowledge with an iPhone/iPad core, deferred-platform policy, modular references, coverage registry, validators, routed skills, AI bootstrap, and commerce coverage.
- [x] Reclassify the AI roadmap for a no-backend learning app: locally executable capabilities are runtime labs; blocked cloud, hardware, and beta-SDK capabilities are tutorial-only modules with architecture and code examples.
- [x] Audit and enforce the reusable/app/task documentation boundary: isolate historical snapshots, remove app/task leakage from reusable docs, and add a validator guardrail.
- [x] Complete a preservation-first documentation cleanup: record recovery provenance, replace destructive/stale inventory tooling, quarantine proven duplicates and raw trace payloads without data loss, retain unique history, validate both stores, and publish the canonical vault.

## Deliberately Deferred Evidence And External Decisions
- [ ] Execute `1.26-S` Simulator gate after explicit authorization, then obtain the user's explicit acceptance before Simulator-verifiable Iteration 2 work.
- [ ] Execute `1.26-D` physical-device gate when hardware is available; do not implement microphone, hardware audio lifecycle, locked-device protection, Apple Intelligence inference, Siri voice, or hardware-performance paths before then.
- [ ] Run archive/signing, dSYM, Privacy Report, and release evidence after explicit authorization and the required environment decisions.
- [ ] Decide whether to add full-text indexing for large text/tag corpora; current database-side filters and result limits improve bounded cases but are not an FTS replacement.
- [ ] Decide whether to migrate legacy imported filenames to hashes and explicitly migrate/protect existing SwiftData store files; new imports are integrity-checked and app-owned content files use complete protection.
- [ ] Select a crash-reporting/CI provider and signing team before adding remote observability or release automation; no analytics or third-party telemetry was guessed.

## Verification Policy
- Allowed now: read-only inspection, compiler-independent static scripts, plist validation, documentation validators, secret scan, and `git diff --check`.
- Not allowed without a separate user authorization: writing/modifying tests, Xcode build, test execution, Simulator UI, physical-device QA, crash injection, Instruments, archive/signing, or App Store upload validation.

## Preserved Product Boundaries
- Iteration 1 remains local-only with no backend, analytics, cloud processing, App Intents, or AI runtime.
- The approved learning-program runtime has no backend or direct cloud provider path. Tutorial modules may explain those architectures but never include credentials, provider configuration, or simulated claims of execution.
- No destructive migration or automatic store reset is permitted.
- `1.26-S` acceptance may unlock only the documented Simulator-verifiable subset of Iteration 2. `1.26-D` remains required for physical-device-only code and any full runtime-completion claim.
- No commit or push is authorized for this project repository.

## Context Transfer Rule
**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
