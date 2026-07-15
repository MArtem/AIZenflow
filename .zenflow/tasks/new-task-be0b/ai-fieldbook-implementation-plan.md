# AI Fieldbook Deterministic Implementation Plan

## Execution Rule

- Work one self-contained block at a time.
- Do not start the next block before reporting the current block.
- Keep one block focused on one user capability or foundation decision.
- Build only when it provides meaningful evidence; avoid cosmetic rebuild churn.
- Use Simulator manual validation for coherent user flows when useful.
- Do not create or modify tests.
- Keep all project/build/cache/log artifacts inside `/Users/Artem/.zenflow`.

## Iteration 1 — Complete App Without AI

### [x] 1.1 Product Contract And Architecture Decisions

- Approve product scope, content types, navigation direction, local-only policy,
  deployment target, architecture, persistence split, iteration boundary, and
  verification policy.
- Verify installed toolchain read-only.
- Deliver product contract, ADRs, and this granular plan.

### [x] 1.2 Create The Independent Xcode Project

- Create one SwiftUI iOS app target named `AIFieldbook`.
- Set deployment target iOS 26.0.
- Configure sandbox-local DerivedData/build paths and `.gitignore` protection.
- Keep only the generated entry point plus minimal launch view.
- Verify project plist and one generic Simulator build.

Completed evidence:

- Created `./AIFieldbook/AIFieldbook.xcodeproj` with one iOS app target and one shared scheme.
- Added only `AIFieldbookApp.swift` and a minimal `LaunchView.swift`.
- Configured iOS 26.0, Swift 6, complete strict concurrency, iPhone target family, generated Info.plist, and no package/test target.
- `plutil` and scheme XML validation succeeded.
- Generic iOS Simulator Debug build succeeded with DerivedData/TMPDIR inside `.zenflow-build`.
- Removed an optional `#Preview` after the first build proved the Preview macro plugin cannot run under the current command sandbox; runtime UI behavior is unchanged.

### [x] 1.3 Establish Native MVP Design Tokens

- Add semantic colors, typography, spacing, radii, and basic control styles.
- Support light/dark appearance and Dynamic Type foundations.
- Do not add real product features yet.

### [x] 1.4 Add App Shell And Navigation Skeleton

- Add Workspace, Capture, Search, and Settings destinations.
- Implement native tab/navigation behavior and empty destination screens.
- Defer the Labs destination itself until Iteration 2; no fake AI surface appears in Iteration 1.

### [x] 1.5 Add SwiftData And File-Storage Foundations

- Introduce version-1 app metadata schema.
- Add `Workspace`, `KnowledgeItem`, `Attachment`, and `Tag` concepts only as
  required by the first user flows.
- Establish durable relative file-reference policy and failure cleanup.

### [x] 1.6 Workspace List And Empty State

- Render workspaces with stable identity.
- Add empty/error/loading states relevant to local persistence.

### [x] 1.7 Create Workspace

- Add create form, validation, save, cancel, and persistence.
- Verify relaunch durability.

### [x] 1.8 Rename And Delete Workspace

- Implement rename separately from delete.
- Define and present contained-item deletion consequence.
- Confirm destructive action immediately before execution.

### [x] 1.9 Create And View Text Note

- Add the first complete item vertical slice: create, save, view, cancel.
- Keep text note behavior independent of future AI.

### [x] 1.10 Edit And Delete Text Note

- Add edit/unsaved-change behavior.
- Reconcile delete with persistence and selected navigation state.

Completed evidence for blocks 1.3-1.10:

- Added system-semantic light/dark colors, Dynamic Type typography, spacing,
  radii, and a reusable card surface without custom Liquid Glass effects.
- Added the four approved native `Tab` destinations and routing foundations;
  Search remains deterministic product behavior and Labs remains absent until Iteration 2.
- Added explicit SwiftData schema v1 and migration plan for workspace,
  knowledge-item, attachment, and tag records; bootstrap failure renders a
  user-visible local-storage failure instead of silently using volatile data.
- Added app-owned file-store staging, relative-reference validation, file
  protection, atomic move, and failure cleanup foundations. No import flow uses
  the store before its later content-specific validation block.
- Added concrete app-local persistence repository plus `@MainActor`
  `@Observable` screen/form state owners with explicit intent methods. No
  protocol, use-case, extra package, or generic action dispatcher was
  introduced.
- Added workspace loading/empty/error/content states, create, rename, open, and
  confirmed cascade delete.
- Added text-note create/view/edit/delete, workspace selection from Capture,
  validation, save/cancel, and unsaved-change confirmation.
- Generic iOS Simulator Debug build succeeded under Swift 6 complete strict
  concurrency. Initial launch and terminate/relaunch both reached the workspace
  empty state on the booted iOS 26.5 Simulator.
- Remaining manual verification: Simulator input automation was unavailable,
  so creating a workspace/note, editing, destructive confirmation, and proving
  saved-record survival across relaunch still require a short human UI pass.

### [x] 1.11 Knowledge Item List

- Add stable ordering, type presentation, workspace scoping, and navigation to
  detail.
- Repeated rows receive narrow immutable state and callbacks.

### [x] 1.12 Tags

- Add user-created tags, assignment/removal, and tag filtering.
- No generated tags.

### [x] 1.13 Deterministic Search

- Search title, text body, filename, tags, and approved safe metadata.
- Add filters, clear-query, and no-result behavior.

### [x] 1.14 Import And View Image

- Add picker flow, validation, durable copy, preview, missing/corrupt failure,
  delete, and cleanup.
- No OCR/classification.

### [x] 1.15 Import And View PDF

- Add PDF validation, durable copy, metadata, preview, delete, and cleanup.
- No OCR/summary/text extraction beyond what is required to preview manually.

### [x] 1.16 Import Supported Document

- Choose the first concrete non-PDF document types immediately before this
  block based on available native support.
- Add one type at a time rather than a generic unbounded importer.

### [x] 1.17 Import And Play Audio

- Validate/copy audio, expose duration/playback state, and clean up on delete.
- Keep audio runtime ownership out of SwiftUI render paths.

Completed evidence for blocks 1.11-1.17:

- Upgraded persistence to explicit schema v2 with a lightweight v1-to-v2
  migration. Installing the v2 app over the existing v1 Simulator container
  opened the workspace UI without falling back to the persistence-error screen.
- Generalized workspace presentation to a stable, workspace-scoped,
  updated-descending knowledge-item list with type, tags, timestamp, and narrow
  immutable row state.
- Added user-created tags, assignment/removal on text and imported items, and
  tag filtering in Search. No generated tags or AI behavior exists.
- Added deterministic on-device search across title, note body, original
  filename, and tag names, with workspace/type/tag filters, clear state, and
  no-result/error states.
- Added explicit file imports for image, PDF, UTF-8 plain text, and audio. The
  first non-PDF document type is intentionally plain text only; arbitrary
  document import remains out of scope.
- Enforced limits: images 25 MB and 20,000 pixels per side; PDFs 50 MB and 500
  pages; UTF-8 text 10 MB; playable audio 100 MB and four hours.
- Import treats provider URLs as untrusted, uses security-scoped access when
  supplied, validates before app-owned staging, applies file protection, moves
  durably, cleans partial writes, and removes the copied file if metadata save
  fails. Original image metadata is replaced during copy so location metadata
  is not retained.
- Added bounded off-main image downsampling, PDFKit preview, Quick Look text
  preview, and an explicit audio playback state owner that releases its timer
  and pauses on disappearance.
- Item/workspace deletion stages owned files before the database mutation,
  rolls files back if persistence deletion fails, and removes abandoned staging
  on next launch.
- Final generic iOS Simulator Debug build succeeded under Swift 6 complete
  strict concurrency. The final build installed and launched on iOS 26.5.
- Remaining manual evidence: picker selection, valid/invalid/oversized fixtures,
  each preview, audio controls, tag interactions, search results, and deletion
  cleanup require a human Simulator pass because UI input automation and test
  writing are unavailable. Migration with populated v1 records is also not yet
  fixture-verified.

### [x] 1.18 Record And Play Audio

- Add microphone permission, recording lifecycle, interruption handling,
  durable save, cancel, playback, and unavailable states.
- Report Simulator-only evidence and physical-device remaining risk.

### [x] 1.19 Add URL Reference

- Validate/normalize `http` and `https` only.
- Add manual title/description, edit, safe open, and delete.
- No automatic web scraping.

### [x] 1.20 Unified Item Detail

- Unify metadata, tags, workspace, edit/move/delete/export entry points.
- Keep type-specific renderers concrete and narrow.

### [x] 1.21 File/Permission/Error Hardening

- Cover permission denied/revoked, unsupported/corrupt input, missing files,
  insufficient space, persistence failure, and interrupted operations.

### [x] 1.22 Settings And Local Data Lifecycle

- Add local-only disclosure, cache cleanup, storage information, export,
  delete-all, and permission guidance.

### [x] 1.23 App Intents Moved To Iteration 2

- User explicitly moved all App Intents out of the non-AI app iteration.
- No App Intent, App Entity, shortcut metadata, or intent adapter is added in
  Iteration 1.

### [x] 1.24 Spotlight Index And Deep Links

- Index approved metadata with stable identifiers.
- Open the correct item/workspace and remove stale index entries.

### [x] 1.25 Accessibility And Localization Implementation

- Review VoiceOver, Dynamic Type, focus, contrast, localized copy, error copy,
  permission copy, and destructive confirmation.

### [x] 1.25A Static Production Remediation

- Replace blanket staging cleanup with manifest-based crash recovery and honest rollback/finalization errors.
- Fix modal mutation refresh identity, URL workspace edits, and deep-link kind verification.
- Add digest-bearing app-owned filenames for new imports, stricter input limits, complete file protection, and retryable persistence startup diagnostics.
- Move export reads/encoding to a SwiftData model actor and replace eager audio decoding with streaming playback/resource release.
- Add recorder interruption, route-change, foreground, draft-replacement, and setup-failure cleanup behavior.
- Add bounded LRU detail caches, database-scoped search filters, a privacy manifest, privacy-safe OSLog failures, Russian plural rules, and expanded translations.
- Static implementation evidence includes Swift 6 compiler type-check. Xcode build, Simulator/device behavior, crash injection, migration, accessibility, privacy report, archive, and Instruments remain part of gate 1.26.

### [ ] 1.26 Iteration 1 Manual Completion Gate

- Execute the approved end-to-end local content matrix.
- Verify relaunch, offline operation, storage cleanup, and unsupported states.
- Record Simulator-only and no-tests remaining risks.
- Do not begin Iteration 2 until the user accepts the gate.

Implementation evidence for blocks 1.18-1.25 and the architecture completion pass:

- Replaced feature-owned dependency construction with one `AppComposition`.
  It owns the repository, file store, root/cached screen models, and modal models.
- Added one `AppCoordinator` with selected-tab ownership and a separate typed
  source-only `AppNavigation.TabRouter` for every tab. Product routes carry only
  stable IDs/value types; tab scenes own their `NavigationStack` destinations.
- Mirrored architecture in the filesystem and Xcode groups: `App`, `Navigation`,
  `Core/DesignSystem`, `Core/Persistence`, `Core/Search`, feature folders, and
  `Resources`; `PackagesInUse/AppNavigation` is compiled source-only.
- Added microphone-permission-aware M4A recording with an explicit recorder
  state/resource owner, app-owned staging, cancellation cleanup, duration state,
  durable save, and existing audio playback integration.
- Added manual URL references with strict `http`/`https` normalization, title and
  notes, edit/open/tag/move/share/delete flows, and no scraping.
- Unified item navigation and actions across text, file/media, audio, and URL
  renderers: tags, move, share/export, delete, metadata, and type-specific edit.
- Added Settings local-only disclosure, app-owned storage size, temporary/export
  cleanup, JSON-plus-Content local export, permission guidance, and staged
  delete-all rollback behavior.
- Added Core Spotlight rebuild with stable identifiers and stale-item removal,
  plus `aifieldbook://workspace/<UUID>` and `aifieldbook://item/<UUID>` parsing
  through the app coordinator. No App Intents code or metadata was introduced.
- Added a custom privacy/URL-scheme plist and Russian translations for primary
  flows. Existing SwiftUI copy uses localized keys and semantic/Dynamic Type
  styles; interactive elements retain labels and combined row semantics.
- Final generic iOS Simulator Debug build succeeded under Swift 6 complete strict
  concurrency. The app installed and launched on iOS 26.5; the custom URL scheme
  was recognized by Simulator and presented the system open confirmation.
- Gate 1.26 remains deliberately open: human interaction is still required for
  CRUD/picker fixtures, actual recording permission/audio, populated migration,
  VoiceOver/Dynamic Type, deep-link confirmation/routing, export/delete-all, and
  relaunch durability. No test files were created and no tests were run.

## Iteration 2 — Add AI One Capability At A Time

### [ ] 2.0 Basic App Intents Foundation

- Add one non-AI intent at a time: create text note, find item, open item, and
  open workspace.
- Add `WorkspaceEntity` and `KnowledgeItemEntity` only as required.
- Keep persistence/product logic outside `perform()` and reuse the app-owned
  navigation/deep-link boundary.

### [ ] 2.1 Capability And Provenance Foundation

- Add capability availability/state and AI result provenance only when AI work
  begins.
- Do not add a model router while only one route exists.

### [ ] 2.2 Vision OCR

### [ ] 2.3 Barcode Recognition

### [ ] 2.4 Deterministic Document Text Extraction

### [ ] 2.5 Natural Language Identification

### [ ] 2.6 Natural Language Tokenization And Entities

### [ ] 2.7 Translation

### [ ] 2.8 Speech Transcription

### [ ] 2.9 Sound Analysis

### [ ] 2.10 Sensitive Content Analysis

### [ ] 2.11 Deterministic Local Processing Pipeline

### [ ] 2.12 Foundation Models Availability Only

### [ ] 2.13 Bounded Local Text Summary

### [ ] 2.14 Guided Structured Extraction

### [ ] 2.15 Streaming And Cancellation

### [ ] 2.16 Context/Token Budgeting

### [ ] 2.17 First Read-Only Local Tool

### [ ] 2.18 Local Retrieval Index

### [ ] 2.19 Grounded Local Answer With Citations

### [ ] 2.20 Outline Generation

### [ ] 2.21 Flashcard Generation

### [ ] 2.22 Quiz Generation

### [ ] 2.23 Action-Plan Draft Generation

### [ ] 2.24 Task-Draft Generation

### [ ] 2.25 AI-Enhanced App Intents

- Add local summarize, ask workspace, and study-material drafts one at a time.
- No cloud fallback and no unconfirmed committed mutation.

### [ ] 2.26 Create ML/Core ML Experiment

- Select one bounded classifier only after the earlier local flows are stable.

### [ ] 2.27 AI Diagnostics

### [ ] 2.28 Manual Evaluation Lab

- This is an explicit internal product Lab, not a hidden replacement for banned
  test targets.

### [ ] 2.29 Iteration 2 Local-AI Completion Gate

- Compare deterministic/local routes, quality, privacy, latency, memory,
  cancellation, unsupported-device behavior, and provenance.

## Deferred iOS 27 Track

Do not schedule until Xcode 27 is available and the APIs are revalidated:

- Core AI;
- `LanguageModel` abstraction;
- Private Cloud Compute model;
- multimodal Foundation Models;
- Dynamic Profiles;
- `SpotlightSearchTool`;
- `OCRTool` / `BarcodeReaderTool`;
- Evaluations framework;
- latest App Schemas and Music Understanding.

## Deferred Cloud Track

Do not schedule until backend, provider, budget, consent, and security ADR are
approved:

1. backend/security boundary;
2. authentication and secrets;
3. one provider text/structured/streaming path;
4. multimodal documents/images/audio;
5. cloud RAG and citations;
6. web grounding;
7. realtime voice;
8. image generation/editing;
9. constrained backend tool workflow;
10. one bounded agent workflow;
11. second provider only after measured justification.
