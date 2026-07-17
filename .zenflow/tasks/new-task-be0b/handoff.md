# Current Task Handoff

## Identifiers And Mandatory Context
- Worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Task: `new-task-be0b`
- Active app: `AI Fieldbook` at `./AIFieldbook`
- Canonical documentation repo: `/Users/Artem/.zenflow/worktrees/documentation-vault`

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

Start with `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`, read its current Level 0 set once, then load only the routes required by the task.

## Completed AI Fieldbook Remediation
- Replaced best-effort file deletion with durable manifest-backed staging, startup recovery, conflict-preserving rollback, and honest finalization errors.
- Fixed modal mutation reload identity, workspace movement during URL edits, deep-link kind validation, URL credential rejection, HTTP warnings, and URL size limits.
- Added bounded image validation, SHA-256 verification for new imports, opaque filenames, complete file protection, backup exclusion, and retryable persistence startup diagnostics.
- Moved export snapshot/encoding to a model actor with cancellation; changed audio playback to streaming `AVPlayer`; added recording interruption/route/background cleanup.
- Added database-side search filters and bounded unfiltered results, LRU detail caches, media release on eviction/reset, and memory-warning cache cleanup.
- Added `PrivacyInfo.xcprivacy`, privacy-safe OSLog diagnostics, expanded Russian localization and plural rules, and accessible error/progress states.
- Reconciled the product contract, architecture decisions, implementation plan, Iteration 1 acceptance gate, AI/lab plan, and local privacy/runtime notes.
- Preserved Iteration 1 as local-only: no backend, analytics, cloud processing, App Intents, or AI runtime were introduced.
- Recorded Simulator-first execution: accepted `1.26-S` unlocks only Simulator-verifiable labs; `1.26-D` retains device-only code and evidence.
- Classified backend, cloud-model, unavailable iOS 27, and unavailable-hardware paths as tutorial-only until their prerequisites are approved.

## Static Evidence
- Swift 6 strict-concurrency whole-source type-check passes with source-only `AppNavigation` included.
- Secret, large-file, forbidden-pattern, localization, and iOS production-framework checks pass.
- SwiftUI hot-path scan reports only reviewed Task-lifecycle candidates; owned export/maintenance tasks cancel or replace prior work, observer tasks follow recorder lifecycle, and remaining view Tasks are user/lifecycle initiated.
- App plist, privacy manifest, Russian strings/stringsdict, and Xcode project plist validation pass; localization keys have no duplicates.
- Documentation index, consistency, boundary, router, and reusable-baseline drift checks pass; `git diff --check` passes.
- Reusable saved prompts and architecture cases are app-neutral; active app boundaries link to reusable guidance instead of copying it. MVVMExample and Tchop legacy snapshots are isolated under non-authoritative `legacy-reference/` areas, and the boundary validator hard-fails active reusable/app leakage.
- Documentation cleanup replaced the destructive worktree sync with a non-destructive deterministic manifest generator, reduced active inventories to root `MANIFEST.md` and `MANIFEST_SUMMARY.md`, corrected quality-first `sol`/`tera`/`luna` routing, and moved obsolete duplicates, misplaced task files, and raw traces into non-authoritative `retired/` quarantine without deleting their content.
- The non-empty readable Tchop trace analysis is retained under `apps/Tchop/legacy-reference/evidence/`; unique archive intake, assistant history, saved-prompt provenance, legacy handbooks, and historical documentation-split material remain retained.
- Canonical manifest freshness and vault-shape checks pass with `3608` files and four app boundaries; active routes have zero missing, optional-missing, unreachable, or unclassified documents.
- Documentation-scoped secret scan passes. The full repository scan still reports seven pre-existing generic-token test fixtures in `TchopAppTests/AppStateTests.swift`; that file is unchanged and tests were not modified under the current restriction.
- No tests were created or modified. No Xcode build, tests, Simulator, device run, crash injection, Instruments, Privacy Report, or archive was performed.

## Remaining Gates And Risks
- Acceptance gate 1.26 is split into `1.26-S` (Simulator) and `1.26-D` (physical device). No Iteration 2 code has started; only a user-accepted `1.26-S` can unblock the documented Simulator subset.
- Simulator evidence still needs CRUD, picker fixtures, imported-audio playback, migration/relaunch, crash recovery, deep links, export/delete-all, Dynamic Type, and system-integration smoke validation. Physical-device evidence still needs microphone recording and lifecycle, locked-device protection, Siri voice, full VoiceOver/touch behavior, and representative performance.
- Text/tag search is improved but not backed by FTS; export still materializes one JSON manifest; legacy imported files are readable but are not retroactively renamed or hash-migrated.
- App-owned content files use complete protection, while an explicit migration/protection policy for pre-existing SwiftData store files remains a separate persistence decision.
- Signing team, CI runner, crash-reporting provider, and remote release observability require user/environment decisions; no provider or telemetry was guessed.
- There is no approved backend, provider account, cloud budget, consent flow, or credential boundary. Do not add Firebase/direct-client cloud code as a shortcut; cloud/global-model material is tutorial-only unless the user explicitly reopens that architecture decision.

## Repository State And Restrictions
- The project worktree contains uncommitted remediation changes by design; do not commit or push this repository without explicit user authorization.
- Canonical AI Fieldbook documentation must be mirrored, validated, committed, and pushed only in `MArtem/AIZenflowDocumentation`.
- The reusable iOS knowledge expansion and preservation-first cleanup are synced and validated for publication in the canonical documentation commit containing this handoff.
- Final review added AI/commerce registry coverage, an exact AI prompt bootstrap mirror, required route/context/drift tools, and `sol`/`tera`/`luna` model-plus-reasoning routing.
- Keep all project/build/cache/log/temp artifacts inside `/Users/Artem/.zenflow`.
- Do not write/modify tests or run builds/tests/Simulator/Instruments without explicit authorization.

## Next Safe Step
After confirming the canonical documentation repository is committed, pushed, clean, and synchronized, request authorization for `1.26-S`. Only its acceptance unlocks a selected Simulator lab and paired tutorial; device-only, iOS 27, backend, and cloud runtime remain gated.
