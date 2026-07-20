# Current Plan

## Goal

Prepare and execute the AI Fieldbook App Intents / Siri Shortcuts / iOS system-integration track as maximally discrete, independently reviewable implementation blocks. Every runtime block must be a complete learning unit that can later map to one intentional project commit without containing preparation for the next capability.

Iteration 1 remains local-only. Simulator runtime work starts only after explicit execution and user acceptance of gate `1.26-S`. Physical-device, Siri voice, Apple Intelligence, iOS 27, backend, and cloud runtime work remain separately gated.

AI Fieldbook is iPhone-only by explicit user decision. iPad/iPadOS implementation, validation, App Intents/Shortcuts behavior, accessibility, localization, and release are outside this plan and product contract.

## Active Model Route

- Planning and architecture freeze: `GPT-5.6 sol`, high reasoning, active mode `сбалансированный`.
- Approved bounded implementation blocks after this plan: `GPT-5.6 tera`, medium reasoning, active mode remains `сбалансированный`.
- Escalate back to `GPT-5.6 sol`, high reasoning only when a block changes architecture, privacy/data exposure, persistence, navigation ownership, public system contracts, or needs the final cumulative review.
- Do not silently change the operating mode or model route.

## Non-Negotiable Execution Contract

Each block below is a potential single commit unit, but no project commit or push is authorized by this plan.

A block is complete only when all of the following are true:

- its user/system behavior is usable without code planned for the next block;
- its ownership, data exposure, error states, localization, accessibility implications, iPhone behavior, and rollback are handled inside the same block;
- it does not add unused protocols, entities, intents, routes, provider layers, extension targets, App Groups, entitlements, feature flags, or placeholders for later work;
- it preserves existing SwiftData data and performs no destructive migration or automatic reset;
- it preserves all unrelated uncommitted changes after a pre-edit diff check;
- its own allowed static evidence is complete;
- build and Simulator evidence are either separately authorized and recorded or explicitly left unverified;
- tests are neither created nor modified;
- the block report names changed files, verification performed, verification withheld, residual risk, and the exact next gate;
- the next block does not start automatically.

If a block finds a defect outside its scope, stop. Fix it only as a separately approved remediation block; do not hide it inside the current capability.

## Current Blocking State

- `1.26-S` is open and not accepted. No Iteration 2 app code may start.
- `1.26-D` is blocked by unavailable physical hardware.
- The user authorized the complete `1.26-S` build and Simulator validation block. This authorization does not extend to tests, Instruments, archive, signing, physical-device work, or Iteration 2 runtime verification.
- The project repository contains existing uncommitted changes. They must be preserved.
- `G0.R1` removed the pre-existing mandatory provider configuration from the active app/build graph. Static plist/project checks passed; unrelated project-file changes and user-owned xcconfig/staging state remain preserved.
- The Debug app builds, installs, and reaches the expected empty state on a representative iPhone Simulator. The remaining `1.26-S` matrix is not accepted.
- iPad is fully outside AI Fieldbook scope. Earlier iPad Simulator observations are non-acceptance evidence and require no remediation.
- UI automation is unavailable because macOS denied Apple Events/Accessibility control of Simulator. Interactive gate items therefore require the user to grant that permission or perform the documented manual matrix; missing interaction evidence must not be treated as a pass.
- Spotlight indexing remains disabled by current privacy policy. App Intents work must not enable, donate, or expand Spotlight exposure as a side effect.

## Selected Architecture

Use the existing single app target. Do not add an App Intents extension, App Group, shared container, new package, backend, provider key, or cloud dependency.

System-facing types remain thin adapters:

`AppIntent / AppEntity / EntityQuery → bounded app-owned read or handoff seam → existing validated deep-link, coordinator, repository, and editor owners`

Architecture invariants:

- App entities are detached `Sendable` system-facing values with stable UUIDs, never live SwiftData records.
- Queries expose only privacy-approved display metadata and use exact or bounded fetches. They never expose note bodies, URLs, file paths, attachment metadata, media, or unrestricted full-store results.
- `perform()` contains parameter validation and adapter orchestration only; it does not duplicate business or persistence logic.
- Open actions reuse the existing validated `aifieldbook` URL/deep-link boundary and coordinator routing.
- `FieldbookRepository` remains scene/main-actor owned and is not injected directly into background intent execution.
- iOS 26 code uses `AppIntent.supportedModes`; do not introduce deprecated `openAppWhenRun`.
- The create-note intent creates only an ephemeral, reviewable draft handoff. SwiftData mutation remains exclusively behind the editor's explicit Save action.
- System exposure is separate from Core Spotlight opt-in and from Siri/Apple Intelligence claims.

## Gate G0 — Resolve Pre-Gate Overlap

### Outcome

Make the existing dirty worktree safe to validate without absorbing unrelated edits into the App Intents phase.

### Work

- Re-read the current diff for every file that a future block may touch.
- Ask the user how to handle the existing debug provider configuration if it still asserts that credentials must exist.
- Confirm that no real secret is present in tracked or ordinary AI-readable files.
- Preserve unrelated changes and record overlap files that require line-level merging later.

### Non-Goals

- No App Intents code.
- No provider integration or substitute credentials.
- No deletion or reset of existing worktree changes.

### Evidence / Exit

- Read-only diff and secret-boundary inspection.
- Explicit user decision for any required remediation.
- If remediation is approved, it becomes its own `G0.Rn` block with independent scope and report.

### Recorded Result

- [x] `G0.R1` was explicitly authorized and completed without App Intents code.
- [x] Mandatory provider plist/build-setting/assertion wiring was removed from the active app/build graph.
- [x] `plutil` validation and scoped `git diff --check` passed.
- [x] Existing unrelated project-file edits and user-owned xcconfig/index state were preserved.

## Gate G1 — Execute And Accept `1.26-S`

### Outcome

Close the documented Simulator acceptance gate before Iteration 2 implementation.

### Work

- Obtain separate authorization to run the complete `1.26-S` Simulator validation block.
- Validate all scenarios listed in `ai-fieldbook-iteration-1-acceptance-gate.md`: CRUD, picker fixtures, imported audio, URL/deep-link flows, populated migration/relaunch, staged-deletion crash recovery, Dynamic Type/localization, export, delete-all, cache/index cleanup, and available system-integration smoke checks.
- Record every pass, failure, explicit user deferral, and remaining risk.
- Resolve each P0/P1 finding as its own separately approved remediation block, then repeat affected evidence.
- Obtain explicit user acceptance of `1.26-S`.

### Non-Goals

- No Iteration 2 code during gate execution.
- No microphone, Siri voice, Apple Intelligence inference, locked-device, full VoiceOver/touch, or hardware-performance claim.

### Evidence / Exit

- All gate criteria pass or are explicitly deferred by the user.
- P0/P1 Simulator findings are closed with evidence.
- User explicitly accepts `1.26-S`.
- Task state records that only the Simulator-verifiable Iteration 2 subset is open.

### Current Evidence

- [x] Complete `1.26-S` build and Simulator validation was explicitly authorized by the user.
- [x] Debug build succeeded with DerivedData, package state, logs, and temporary artifacts scoped to `/Users/Artem/.zenflow`.
- [x] The app installed and cold-launched to the expected empty state on a representative iPhone Simulator.
- [x] No provider credential assertion blocks launch.
- [x] URL-scheme registration is present; a warm custom-URL request reaches the iOS system open-confirmation boundary.
- [ ] `G1.P1-001`: on the supported iPhone at Accessibility XXXL, the first-launch empty-state CTA is partially obscured by the tab bar and the content is not visibly scrollable. This blocks the primary create-workspace flow and must be closed in a separately approved remediation block before `1.26-S` acceptance.
- [ ] Accept the system open confirmation and verify invalid, missing, valid, and kind-mismatched deep-link routing.
- [ ] Complete workspace and every knowledge-item CRUD flows.
- [ ] Complete picker fixture, imported-audio, URL warning/rejection, migration/relaunch, staged-deletion crash recovery, Dynamic Type/localization, export, delete-all, cache, and index-cleanup scenarios.
- [ ] Record passes, failures, user-approved deferrals, and remaining risks for every acceptance item.
- [ ] Close any P0/P1 Simulator findings with separately approved remediation and repeated evidence.
- [ ] Obtain explicit user acceptance of `1.26-S`.

Interactive items remain blocked on this host until Simulator UI control is granted through macOS Accessibility/Automation or the user performs the manual matrix. This evidence gap does not authorize Iteration 2 code.

### Proposed Remediation G1.R1 — Accessible Empty-State Overflow

- Scope only the supported iPhone empty/error workspace state at accessibility text sizes.
- Preserve the native `ContentUnavailableView` semantics, existing create action, localization, and standard-size layout.
- Provide safe vertical overflow/scroll behavior so the title, explanation, and CTA remain reachable above the tab bar at Accessibility XXXL.
- Do not refactor navigation, tabs, workspace state ownership, other feature screens, App Intents, persistence, or tests in this block.
- Evidence after separate approval: scoped static review, authorized iPhone Simulator screenshots at standard and Accessibility XXXL, then repeat the affected first-launch interaction in the manual matrix.

## Block A1 — Open Workspace Vertical Slice

### Learning Unit

Model one private local domain noun as an App Entity, resolve it with a bounded query, and route one finished read-only action through existing validated navigation.

### Scope

- Add `WorkspaceEntity` with stable UUID identity and minimal display representation.
- Add exact-ID resolution and bounded name matching/suggestions using the smallest justified query protocol in the iOS 26.5 SDK.
- Add the smallest concrete read data source required by this intent, backed by a model-actor/container pattern; do not inject the scene `FieldbookRepository` or add a generic bridge for future actions.
- Add a discoverable `Open Workspace` intent using the entity.
- Use current iOS 26 `supportedModes` and the existing validated workspace deep link.
- Keep `perform()` free of SwiftUI, live SwiftData models, and coordinator ownership.
- Omit deleted IDs and handle missing/deleted workspace, malformed identifiers, cold launch, warm foreground, and cancellation with localized output.
- Keep supported iPhone navigation correct across cold and warm launch.
- Include all English/Base and Russian strings required by this slice.

### Likely Files

- `AIFieldbook/AIFieldbook/SystemIntegration/AppIntents/FieldbookIntentDataSource.swift`
- `AIFieldbook/AIFieldbook/SystemIntegration/AppIntents/WorkspaceEntity.swift`
- `AIFieldbook/AIFieldbook/SystemIntegration/AppIntents/OpenWorkspaceIntent.swift`
- `AIFieldbook/AIFieldbook/Core/Search/FieldbookSearchIndex.swift` only if extending existing bounded read ownership is simpler than a dedicated concrete data source
- Base/Russian localization resources
- `AIFieldbook/AIFieldbook.xcodeproj/project.pbxproj`
- existing deep-link/navigation files only if an evidenced defect prevents reuse

### Non-Goals

- No item entity/action, explicit Find intent, App Shortcut provider, workspace mutation, generic dependency abstraction, or new navigation architecture.

### Evidence / Exit

- Static review proves stable IDs, bounded fetches, cancellation, Swift 6 isolation, privacy-minimal values, parameter/mode correctness, URL construction, error mapping, and ownership.
- If separately authorized: build, then manual Shortcuts execution on a representative iPhone Simulator for cold/warm app, valid workspace, and deleted workspace.

### Rollback

Remove only the data-source/entity/intent slice and its strings/project references; no persistent schema or user data changes exist.

### Potential Commit

`feat(app-intents): add open workspace vertical slice`

## Block A2 — Find Knowledge Items Vertical Slice

### Learning Unit

Represent heterogeneous local content as one privacy-minimal entity and expose a useful bounded Find action.

### Scope

- Add `KnowledgeItemEntity` with stable UUID identity and only `title`, localized kind, and workspace name as system-visible display/disambiguation metadata.
- Add exact-ID and bounded `EntityStringQuery` behavior; do not add `EntityPropertyQuery` until a separate learning need exists.
- Add a standalone `Find Knowledge Items` intent with a required non-empty query, optional `WorkspaceEntity`, and a hard maximum of 20 returned entities.
- Matching may inspect approved local title/body/tag/filename fields through existing local search ownership, but the entity/result never exposes body, tags, URL values, filenames, file paths, attachment metadata, or media.
- Validate stored kind; omit corrupt, stale, or deleted records.
- Define explicit empty-query, no-result, cancellation, read-failure, and deleted-workspace behavior.
- Add all required Base/Russian localization in this block.

### Likely Files

- `AIFieldbook/AIFieldbook/SystemIntegration/AppIntents/KnowledgeItemEntity.swift`
- `AIFieldbook/AIFieldbook/SystemIntegration/AppIntents/FindKnowledgeItemsIntent.swift`
- the concrete data source introduced by A1, expanded only with item operations required by this slice
- `AIFieldbook/AIFieldbook/Core/Search/FieldbookSearchIndex.swift` only for the required bounded matching behavior
- localization resources
- `AIFieldbook/AIFieldbook.xcodeproj/project.pbxproj`

### Non-Goals

- No open-item action, property-comparator lab, search UI change, Spotlight indexing, AI classification, App Shortcut provider, or mutation.

### Evidence / Exit

- Static review proves the 20-result cap, safe output metadata, stable identity, kind validation, empty/no-result/deleted behavior, cancellation, and isolation.
- If separately authorized: build and manual Shortcuts execution with title/body/tag matching, optional workspace scope, empty/no-result queries, populated/empty stores, deleted entities, and a representative iPhone Simulator.

### Rollback

Remove only the item entity/find-intent additions and concrete data-source extensions; A1 remains functional and no schema/data changes exist.

### Potential Commit

`feat(app-intents): add bounded local item discovery`

## Block A3 — Open Knowledge Item Vertical Slice

### Learning Unit

Open heterogeneous content from a typed system action without duplicating routing rules.

### Scope

- Add only `Open Knowledge Item` using the completed `KnowledgeItemEntity`.
- Route through `aifieldbook://item/<UUID>` and let existing composition/repository ownership resolve and validate the current stored kind; do not trust or duplicate a system-supplied kind.
- Preserve current coordinator ownership and item-specific destination selection.
- Handle deleted items, stale/mismatched kinds, cold/warm app launch, and cancellation with localized output.

### Likely Files

- `AIFieldbook/AIFieldbook/SystemIntegration/AppIntents/OpenKnowledgeItemIntent.swift`
- Base/Russian localization resources
- `AIFieldbook/AIFieldbook.xcodeproj/project.pbxproj`
- existing deep-link/navigation files only for a demonstrated reuse defect

### Non-Goals

- No entity/query expansion, editing, deletion, tags, sharing, App Shortcuts provider, or Spotlight change.

### Evidence / Exit

- Static ownership/privacy/error review.
- If separately authorized: build and manual Shortcuts runs for every current item kind, missing item, mismatched kind, and cold/warm launch on a representative iPhone Simulator.

### Rollback

Remove the intent and its resources; both entity contracts remain intact.

### Potential Commit

`feat(app-intents): open a discovered knowledge item`

## Block A4 — Draft-Only Create Text Note Vertical Slice

### Learning Unit

Accept structured system input while keeping persistence behind explicit in-app review.

### Scope

- Before coding, close Decision D1 below for title/body limits and confirmation wording.
- Define a value-only `TextNoteDraft` containing optional title/body and optional workspace UUID with deterministic size/empty-input validation.
- Add `Create Text Note` parameters using typed `WorkspaceEntity` instead of an ambiguous workspace string.
- Use foreground execution through iOS 26 `supportedModes = .foreground(.immediate)`.
- Add only the concrete `Sendable` draft ingress required by this action; do not create a generic intent bridge/event bus.
- Private draft text must not appear in a URL, log, Spotlight index, analytics event, UserDefaults, or SwiftData.
- Prefer an in-memory foreground ingress. If lifecycle evidence proves a token handoff necessary, keep it bounded, consume-once, cancellable, process-local, and free of durable files.
- Extend `TextNoteEditorViewModel` and `AppComposition` to prefill title/body/workspace and revalidate the workspace before presentation.
- Preserve the invariant that only `TextNoteEditorViewModel.saveTapped()` creates a record. Existing in-app Save is the confirmation boundary.
- Define explicit cancel/discard, missing workspace, stale entity, empty draft, oversized text, cold/warm launch, and duplicate-invocation behavior.
- Add all Base/Russian strings and privacy-safe errors in this block.

### Likely Files

- `AIFieldbook/AIFieldbook/SystemIntegration/AppIntents/CreateTextNoteIntent.swift`
- at most one concrete draft-ingress file if required
- `AIFieldbook/AIFieldbook/Features/Capture/TextNoteViewModels.swift`
- `AIFieldbook/AIFieldbook/Navigation/AppCoordinator.swift` only for the value-only draft presentation contract
- `AIFieldbook/AIFieldbook/App/AppComposition.swift`
- `AIFieldbook/AIFieldbook/App/AppShellView.swift` only if presentation rendering needs an additive case change
- Base/Russian localization resources
- `AIFieldbook/AIFieldbook.xcodeproj/project.pbxproj`

### Non-Goals

- No direct SwiftData creation from `perform()`, automatic Save, background mutation, AI-generated text, voice capture, cloud processing, durable draft queue/file, App Shortcut provider, or generic navigation dispatcher.

### Evidence / Exit

- Static data-flow/threat review proves no off-device transmission, content logging, URL leakage, implicit persistence, or stale handoff retention.
- Static ownership review proves the editor remains the only mutation owner.
- If separately authorized: build and manual Shortcuts flows on a representative iPhone Simulator for prefill, workspace resolution, edit-before-save, explicit save, cancel/discard, repeated invocation, deleted workspace, cold/warm launch, and relaunch proving unsaved drafts were not persisted.

### Rollback

Remove the intent/ingress and revert only additive draft-prefill presentation changes. Existing manual note creation and stored notes remain compatible.

### Potential Commit

`feat(app-intents): open a reviewable text note draft`

## Block A5 — Curated App Shortcuts Discovery

### Learning Unit

Publish only the four finished runtime actions as zero-setup App Shortcuts after their contracts are stable.

### Scope

- Add one `AppShortcutsProvider` for Open Workspace, Find Knowledge Items, Open Knowledge Item, and draft-only Create Text Note.
- Use current iOS 26.5 initializers, SF Symbols, concise titles, and phrases containing the application-name token.
- Add complete English/Base and Russian phrases/titles in the same block.
- Keep the curated set small and ensure Create Text Note wording never implies persistence before in-app Save.
- Register/update shortcut parameters only through the SDK-required lifecycle seam and merge carefully with existing dirty `AIFieldbookApp.swift` changes.

### Likely Files

- `AIFieldbook/AIFieldbook/SystemIntegration/AppIntents/AIFieldbookShortcuts.swift`
- `AIFieldbook/AIFieldbook/App/AIFieldbookApp.swift` only if SDK-required registration cannot remain provider-only
- localization resources
- `AIFieldbook/AIFieldbook.xcodeproj/project.pbxproj`

### Non-Goals

- No intent/entity/query behavior changes, new parameters, Siri voice validation, Spotlight donation, Action Button claim, or device-only surface.

### Evidence / Exit

- Static check of provider composition, phrases, symbols, localization, privacy, shortcut count, and accurate draft wording.
- If separately authorized: build and Shortcuts discovery/run on a representative iPhone Simulator in English and Russian.
- Siri voice remains explicitly unverified.

### Rollback

Remove the provider/registration and its phrases; the underlying intents remain ordinary Shortcuts actions where supported.

### Potential Commit

`feat(shortcuts): publish curated fieldbook actions`

## Decision D1 — Create Note Input Contract

Approved by the user before implementation:

- maximum title length: 200 user-perceived characters;
- maximum body length: 20,000 user-perceived characters;
- both fields may be empty when the intent opens the editor; existing Save validation still prevents an empty persisted note;
- the visible in-app editor plus explicit Save is sufficient confirmation because the intent itself performs no mutation.

## Gate G2 — Simulator App Intents Acceptance

### Outcome

Accept the Simulator-verifiable App Intents subset without expanding claims to Siri or hardware.

### Work

- Obtain separate build and Simulator authorization.
- Re-run static Swift 6/concurrency, privacy, localization, project-file, forbidden-pattern, secret, and diff checks relevant to the changed files.
- Run one coherent build only after all individually reviewed blocks have their own static evidence, unless a block required an earlier authorized compile to resolve API signatures.
- Manually verify every completed intent/action in Shortcuts on a representative iPhone Simulator.
- Cover cold/warm app, English/Russian, deleted/stale entities, empty store, populated store, cancellation, draft discard/save, deep links, relaunch, Dynamic Type where system/app UI is involved, and no Spotlight enablement.
- Review the complete App Intents diff on `GPT-5.6 sol`, high reasoning before a cumulative completion claim.

### Exit

- P0/P1 findings are closed in separate remediation blocks.
- Every runtime claim is tied to static/build/Simulator evidence.
- Siri voice, Apple Intelligence, physical-device, distribution, and performance claims remain open.
- The user explicitly accepts the Simulator App Intents subset.

## Tutorial Track — Separate Documentation Units

Tutorials do not add runtime code, targets, entitlements, credentials, fake results, or unavailable UI. Each unit must live in the AI Fieldbook app-specific documentation boundary, cite current official Apple sources, state prerequisites and unsupported evidence, and remain independently publishable in the canonical documentation repository.

### T1 — Siri Voice Invocation

- Explain phrase resolution, disambiguation, locale/region, authorization, cold/warm launch, and physical-device evidence.
- Reference the implemented intents without claiming voice success.
- Future gate: `1.26-D` plus an authorized physical-device Siri matrix.
- Potential docs commit: `docs(ai-fieldbook): add Siri voice validation tutorial`.

### T2 — Onscreen Content And Siri Context

- Explain app-entity/NSUserActivity or applicable schema mapping, scene ownership, stale content, privacy, and current SDK/OS availability.
- Keep Assistant Schemas or newer API examples version-labelled and tutorial-only when unavailable in Xcode 26.5.
- Potential docs commit: `docs(ai-fieldbook): document onscreen Siri entity context`.

### T3 — Interactive Snippets

- Explain snippet lifecycle, interaction, confirmation, failure, privacy, accessibility, localization, and device/OS evidence.
- Do not add `SnippetIntent` runtime code in the stable target.
- Potential docs commit: `docs(ai-fieldbook): add interactive snippets tutorial`.

### T4 — Visual Intelligence

- Explain `IntentValueQuery`, image input trust, entity matching, false-positive handling, privacy, device/region/OS prerequisites, and future evaluation.
- No camera/image upload or runtime integration.
- Potential docs commit: `docs(ai-fieldbook): add visual intelligence tutorial`.

### T5 — Spotlight Entity Indexing And Donations

- Compare App Entity exposure, Core Spotlight indexing, donations, deletion/staleness, and user privacy control.
- Preserve the current disabled-by-default runtime policy unless the user separately approves an opt-in product decision.
- Potential docs commit: `docs(ai-fieldbook): explain private entity indexing choices`.

### T6 — Hardware And AI-Enhanced Intents

- Separate microphone/camera/audio intents, Action Button, Apple Intelligence/Foundation Models actions, and iOS 27 App Schemas into explicit prerequisite/evidence sections.
- No runtime work until underlying capability is physically proven and its own gate is accepted.
- No cloud fallback, backend, credentials, or simulated AI output.
- Potential docs commit: `docs(ai-fieldbook): map device-only and AI intent gates`.

## Explicitly Deferred Runtime Scope

- Siri voice execution and phrase-quality claims.
- Apple Intelligence, Foundation Models, onscreen Siri context, Assistant Schemas, interactive snippets, Visual Intelligence, camera/microphone/audio intents, Action Button hardware behavior, and representative performance/energy behavior.
- iOS 27 SDK/runtime APIs until Xcode 27 is available and revalidated.
- Spotlight indexing/donations until an explicit privacy opt-in product decision.
- Backend, cloud providers, provider credentials, cloud AI, cloud RAG, realtime cloud voice, and global-model tools.
- App Intent automated tests until the user explicitly opens a test-writing phase.
- Project commits/pushes until explicitly authorized.

## Verification Policy

- Allowed during planning: read-only inspection and plan-file editing only.
- Allowed during future implementation by default: read-only inspection, scoped static checks, documentation checks, secret scan, and `git diff --check` when relevant.
- Requires separate authorization: Xcode build, test execution, Simulator UI, physical-device QA, crash injection, Instruments, archive/signing, and App Store validation.
- Tests remain prohibited: do not create or modify AppIntentsTesting, XCTest, Swift Testing, UI-test, or disguised test-like files.
- Build success proves compilation/metadata only; Shortcuts behavior needs Simulator evidence, and Siri voice needs physical-device evidence.

## Preserved Iteration 1 Baseline

The completed Iteration 1 remediation remains the starting point: crash-recoverable deletion, validated local imports, bounded search/cache behavior, local-only privacy, localization/accessibility foundations, strict-concurrency static evidence, and no backend/cloud/App Intents/AI runtime. The detailed completed history remains in the implementation plan and handoff; it must not be reimplemented inside this phase.

## Context Transfer Rule

Active operating mode: `сбалансированный`.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
