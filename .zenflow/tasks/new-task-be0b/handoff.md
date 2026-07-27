# Current Task Handoff

## Identifiers And Mandatory Context
- Worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Task: `new-task-be0b`
- Active app: `AI Fieldbook` at `./AIFieldbook`
- Canonical documentation repo: `/Users/Artem/.zenflow/worktrees/documentation-vault`

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

Active operating mode: `сбалансированный`. The current user-selected route is `GPT-5.6 sol`, high reasoning. Apply the canonical command-time model decision: proceed when this route is adequate; otherwise stop before task actions and require the documented switch. The user may switch explicitly to `качество` or `эконом`; a one-off model selection does not change the active mode.

## Active Collaboration Protocol
- Work code-first in self-contained iterations: targeted inspection → one patch → one relevant static check → stop for the user's build/UI QA.
- The user runs builds, tests, Simulator UI, screenshots, Instruments, archive, and signing until explicitly delegating a specific verification action.
- Do not use subagents, model/reasoning switches, browsing, extended research, broad documentation rereads, runtime verification, or scope sweeps without first stating need, expected token cost, benefits, trade-offs, and the smaller alternative, then receiving approval.
- A same-pattern sweep needs explicit approval and may touch no more than two or three source files. Seek a checkpoint before work expected to touch more than three files or consume roughly more than 2–3% of the weekly budget.
- Mandatory documentation is read once per selected route; later reads and diffs must be targeted. Synchronize canonical documentation only at meaningful boundaries or when explicitly requested.

Start with `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`, read its current Level 0 set once, then load only the routes required by the task.

## Completed AI Fieldbook Remediation
- Completed the static M1–M15 Presentation migration. Feature screens now use explicit
  `Screen → ViewModel/ViewState/Builder → passive Components` slices where state ownership is
  required; the stateless Capture chooser deliberately uses only `Screen → passive Components`.
- Removed the final obsolete aggregate presentation files after relocating shared tags, imported
  file previews, image downsampling, and audio playback to their feature-owned physical folders.
- M12 Imported Item Detail and M13 Audio Recorder both pass the authorized Debug generic iOS
  Simulator build. The user reported the current M15 Debug build succeeded, confirming compile
  integration for the M1–M15 graph, and subsequently reported that the complete M14–M15 UI
  verification passed, including the Settings edge-flow.
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
- Defined AI Fieldbook as fully iPhone-only by explicit user decision. The existing Xcode target already uses `TARGETED_DEVICE_FAMILY = 1`; ADR-009 records the app-specific exception and excludes iPad from product, App Intents, acceptance, and release scope.
- Removed the pre-existing mandatory AI provider configuration from the active app/build graph without touching the preserved user-owned xcconfig/index state or unrelated project-file changes.

## Active Iteration 2 AI Slice
- M16 implements the approved combined `2.1` capability/provenance foundation and `2.2` image
  OCR slice. Imported images expose a manual local Apple Vision action; PDF, text-document, and
  audio details do not expose it.
- `RecognizeTextRequest.revision3` runs in a composition-owned actor outside `MainActor`. The
  ViewModel owns task identity, cancellation, stale-result rejection, and explicit UI state.
- Additive SwiftData V3 stores only the latest local OCR result with source IDs, capability,
  route/provider/model labels, processor version, source revision, completion state, timestamp,
  confidence, latency, and user-edited flag. Source deletion cascades to derived results; export
  format V2 includes the result; failed persistence rolls back without changing the original.
- The UI shows processing/cancel, completed, empty, failure, provenance, and uncertainty copy.
  Result text is selectable. No network, cloud provider, permission, automatic execution, PDF OCR,
  editing, batch processing, or model router was added.

## Static Evidence
- M15 Swift syntax parse, Xcode project plist validation, source membership/path inspection,
  stale-symbol/path scans, and `git diff --check` pass. No old aggregate presentation filename or
  duplicate `CaptureView` symbol remains in the app source graph.
- M14–M15 user-reported verification: the current Debug build and complete UI verification passed,
  including the Settings edge-flow. Tests were not reported or run by the agent.
- M16 static evidence: current SDK/API inspection, Swift syntax parse, project plist/source-path
  validation, Russian localization key inspection, and Swift 6 complete strict-concurrency
  whole-source type-check pass. The type-check used a worktree-scoped module cache. No build,
  tests, or Simulator run was performed for M16.
- Swift 6 strict-concurrency whole-source type-check passes with source-only `AppNavigation` included.
- Secret, large-file, forbidden-pattern, localization, and iOS production-framework checks pass.
- SwiftUI hot-path scan reports only reviewed Task-lifecycle candidates; owned export/maintenance tasks cancel or replace prior work, observer tasks follow recorder lifecycle, and remaining view Tasks are user/lifecycle initiated.
- App plist, privacy manifest, Russian strings/stringsdict, and Xcode project plist validation pass; localization keys have no duplicates.
- Documentation index, consistency, boundary, router, and reusable-baseline drift checks pass; `git diff --check` passes.
- Reusable saved prompts and architecture cases are app-neutral; active app boundaries link to reusable guidance instead of copying it. MVVMExample and Tchop legacy snapshots are isolated under non-authoritative `legacy-reference/` areas, and the boundary validator hard-fails active reusable/app leakage.
- Documentation cleanup replaced the destructive worktree sync with a non-destructive deterministic manifest generator, reduced active inventories to root `MANIFEST.md` and `MANIFEST_SUMMARY.md`, corrected quality-first `sol`/`tera`/`luna` routing, and moved obsolete duplicates, misplaced task files, and raw traces into non-authoritative `retired/` quarantine without deleting their content.
- Three supplied 20-page model-routing documents were structurally and visually reviewed. Their useful mode distinctions were normalized into the single reusable routing rule: persistent `качество`/`сбалансированный`/`эконом` modes, mode-aware optional versus required model switches, stable high-risk floors, and no duplicated price or provider-positioning claims.
- The non-empty readable Tchop trace analysis is retained under `apps/Tchop/legacy-reference/evidence/`; unique archive intake, assistant history, saved-prompt provenance, legacy handbooks, and historical documentation-split material remain retained.
- Canonical manifest freshness and vault-shape checks pass with `3608` files and four app boundaries; active routes have zero missing, optional-missing, unreachable, or unclassified documents.
- Documentation-scoped secret scan passes. The full repository scan still reports seven pre-existing generic-token test fixtures in `TchopAppTests/AppStateTests.swift`; that file is unchanged and tests were not modified under the current restriction.
- No tests were created, modified, or run. The user authorized the complete `1.26-S` build/Simulator block: Debug build succeeded with worktree-scoped artifacts, and the app installed and reached the expected empty state on a representative iPhone Simulator. No physical-device run, crash injection, Instruments, Privacy Report, archive, or signing was performed.

## Remaining Gates And Risks
- M16 still needs the user's build and focused runtime verification: V2 → V3 migration/relaunch,
  text/empty/cancel/failure/retry OCR states, result persistence and copy, non-image exclusion,
  export/delete lifecycle, and preservation of the original imported image.
- AI Fieldbook is fully iPhone-only by explicit user decision. The Xcode target already uses `TARGETED_DEVICE_FAMILY = 1`; iPad/iPadOS implementation, validation, App Intents/Shortcuts behavior, accessibility, localization, and release are outside scope. This is an app-specific exception to the reusable iPhone+iPad baseline, recorded in ADR-009.
- Acceptance gate 1.26 is split into `1.26-S` (Simulator) and `1.26-D` (physical device). The user explicitly accepted `1.26-S`; `1.26-D` remains device-only and closed.
- App Intents A1 is implemented in `AIFieldbook/AIFieldbook/SystemIntegration/AppIntents/OpenWorkspaceIntent.swift`: a detached privacy-minimal `WorkspaceEntity`, bounded model-actor reads, a discoverable `OpenWorkspaceIntent`, and validated workspace deep-link handoff. `AIFieldbook/AIFieldbook/App/AIFieldbookApp.swift` refreshes App Shortcut parameters at launch. No tests were changed.
- App Intents A2 is implemented as separate source contracts: `FieldbookIntentDataSource.swift`, `WorkspaceEntity.swift`, `OpenWorkspaceIntent.swift`, `KnowledgeItemEntity.swift`, and `FindKnowledgeItemsIntent.swift`. It finds at most 20 local items with a required non-empty query and optional workspace scope. System-visible results contain only title, localized kind, and workspace name; search-only body/tag/filename matching never escapes the model actor. No mutation, Spotlight, open-item action, or App Shortcut was added.
- During the user-authorized A2 diagnosis, the initial project-file object-ID collision and one entity initializer access error were corrected. A Debug build then succeeded, installed, and launched to the iPhone Simulator workspace UI without a crash. Tests were not run.
- A1 static/build evidence completed during the user-authorized Shortcuts investigation. Runtime execution in the iOS 26.5 Simulator is blocked outside app code: `linkd` reports missing `AppShortcutEntity` in `com.apple.siriactionsd` and cannot resolve providers. Restarting the Simulator did not help. On a clean iOS 18.2 Simulator, the same unsigned/no-Team-ID TchopApp registers its App Shortcuts provider normally. Do not add signing as a workaround; the user explicitly declined it.
- Simulator evidence still needs CRUD, picker fixtures, imported-audio playback, migration/relaunch, crash recovery, deep links, export/delete-all, Dynamic Type, and system-integration smoke validation. Physical-device evidence still needs microphone recording and lifecycle, locked-device protection, Siri voice, full VoiceOver/touch behavior, and representative performance.
- Simulator UI automation is blocked because macOS denied Apple Events/Accessibility control. A custom URL request reaches the iOS open-confirmation dialog, but accepting it and the remaining interactive matrix require the user to grant UI-control permission or perform the documented manual iPhone validation.
- `G1.P1-001` was remediated in the workspace empty/error state and the user reported the resulting layout as visually acceptable. It no longer blocks `1.26-S`; the remaining manual matrix and explicit user acceptance still do.
- Text/tag search is improved but not backed by FTS; export still materializes one JSON manifest; legacy imported files are readable but are not retroactively renamed or hash-migrated.
- App-owned content files use complete protection, while an explicit migration/protection policy for pre-existing SwiftData store files remains a separate persistence decision.
- Signing team, CI runner, crash-reporting provider, and remote release observability require user/environment decisions; no provider or telemetry was guessed.
- There is no approved backend, provider account, cloud budget, consent flow, or credential boundary. Do not add Firebase/direct-client cloud code as a shortcut; cloud/global-model material is tutorial-only unless the user explicitly reopens that architecture decision.

## Repository State And Restrictions
- The project worktree contains uncommitted remediation changes by design; do not commit or push this repository without explicit user authorization.
- Canonical AI Fieldbook documentation must be mirrored, validated, committed, and pushed only in `MArtem/AIZenflowDocumentation`.
- The iPhone-only product contract, ADR-009, acceptance gate, and task state are canonical in the documentation vault. The durable discrete App Intents plan is `apps/AIFieldbook/plans/app-intents-discrete-implementation-plan.md`; the local `plan.md` is deliberately limited to the active executable checklist.
- The reusable iOS knowledge expansion and preservation-first cleanup are synced and validated for publication in the canonical documentation commit containing this handoff.
- Final review added AI/commerce registry coverage, an exact AI prompt bootstrap mirror, required route/context/drift tools, and `sol`/`tera`/`luna` model-plus-reasoning routing.
- Keep all project/build/cache/log/temp artifacts inside `/Users/Artem/.zenflow`.
- Do not write or modify tests. There is no current authorization to run another build, tests,
  Simulator UI, physical-device QA, Instruments, archive, or signing. Keep runtime verification
  user-owned unless the user explicitly authorizes a new bounded block.

## Next Safe Step
The user runs the M16 build and focused OCR/migration/UI matrix recorded in `plan.md`. After the
user reports results, fix only demonstrated M16 defects or accept the block and synchronize the
canonical AI Fieldbook roadmap. Keep A1/A2 Shortcuts runtime evidence recorded as blocked by the
iOS 26.5 Simulator regression; device-only Siri voice, iOS 27, backend, and cloud runtime remain
gated. Do not begin A3 or another AI capability automatically.
