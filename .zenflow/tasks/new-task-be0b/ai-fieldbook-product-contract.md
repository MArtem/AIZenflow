# AI Fieldbook Product Contract

## Status

- Approved for planning: 2026-07-12.
- Product: independent internal-only iOS learning application.
- Working name: `AI Fieldbook`.
- Current implementation state: native app shell, SwiftData schema v2, workspace and text-note CRUD, tags, deterministic search, and validated app-owned image/PDF/plain-text/audio import and viewing exist; no package, test target, audio recording, URL references, App Intent, or AI capability has been added.
- Current completed block: Iteration 1 / Block 1.17.
- Governing AI prompt: `./docs/agent-prompts/AI_iOS_MASTER_PROMPT.md`.

## Product Goal

Create a private-first multimodal knowledge workspace that is useful before any
AI capability is added. A user manually captures, imports, organizes, searches,
views, edits, exports, and deletes content. Iteration 2 adds AI capabilities to
the finished product one bounded capability at a time.

The app is a learning product, but authored runtime behavior must keep the same
correctness, privacy, accessibility, localization, and failure-state quality bar
as a production application.

## Target User

- Primary user: the developer/owner learning modern Apple-platform AI.
- Distribution: internal-only.
- Accounts: none in Iteration 1.
- Sync/backend: none in Iteration 1.
- Cloud processing: forbidden until separately approved.

## Approved Platform Baseline

- Toolchain verified locally: Xcode 26.5 (`17F42`).
- Simulator SDK verified locally: iOS 26.5.
- Installed runtimes observed: iOS 18.2 and iOS 26.5.
- Proposed deployment target approved by the user: iOS 26.0.
- Runtime validation currently available: iOS Simulator only.
- Physical-device-only behavior remains unverified until a device is available.
- Project baseline: Swift 6 language mode with complete strict-concurrency checking; UI state ownership remains explicit rather than relying on module-wide default MainActor isolation.

## Iteration Boundary

### Iteration 1 — Complete Non-AI Product

The user can work with content manually. No Foundation Models, Core ML, Vision
analysis, Speech transcription, semantic retrieval, generative prompt, model
router, AI result schema, cloud provider, or fake AI response is added.

### Iteration 2 — AI Capabilities

AI begins only after the Iteration 1 completion gate is accepted. Deterministic
Apple intelligence frameworks come first, then local generative capabilities,
App Intents enhanced with AI, custom ML, evaluation, and later gated iOS 27 and
cloud tracks.

## Iteration 1 Content Types

Required:

1. Text note.
2. Photo/image import.
3. PDF import.
4. Supported document import.
5. Audio-file import.
6. Audio recording.
7. URL reference.

Video is a deliberate non-goal for Iteration 1. It adds storage, playback,
thumbnail, lifecycle, and memory scope without being required to prove the base
product. It can be introduced later as a separate approved block.

## Primary Navigation

The initial product shell contains:

- **Workspace**: workspaces and their knowledge items.
- **Capture**: entry points for supported content types.
- **Search**: deterministic local search and filters.
- **Labs**: non-functional informational destination until Iteration 2; it must
  not simulate working AI.
- **Settings**: local-only disclosure, storage/data lifecycle, permissions,
  diagnostics preferences, export, and delete-all entry points.

Navigation is native SwiftUI with an app coordinator/router foundation from the
initial app shell. The coordinator owns selected tab, per-tab stacks, modal
presentation, deep links, and cross-feature routing. Even a small internal app
must not start as isolated `NavigationStack` fragments without a shared routing
owner.

## Core Domain Concepts

### Workspace

A user-owned container for related knowledge items.

Required behavior:

- create;
- rename;
- open;
- list;
- delete after confirmation;
- persist through relaunch.

### Knowledge Item

A source-neutral content record owned by one workspace.

Required behavior:

- create/import;
- inspect;
- edit supported fields;
- move between workspaces;
- tag;
- search;
- export/share where supported;
- delete with associated local-file cleanup;
- persist through relaunch.

### Attachment

A durable app-owned file reference. Temporary provider/picker URLs are never
persisted as the source of truth.

### Tag

A user-created organizational label. Iteration 1 never generates tags with AI.

## Primary User Flows

### First Launch

1. The app opens without an account or network request.
2. It explains that data is stored locally.
3. The user sees a clear empty state and can create a workspace.

### Create Workspace

1. User opens create flow.
2. Enters a valid name.
3. Saves or cancels.
4. Saved workspace appears immediately and after relaunch.

### Create Text Note

1. User selects a workspace.
2. Enters title/body.
3. Saves or cancels.
4. Invalid/empty behavior follows the approved validation rule.
5. Item is editable and persists through relaunch.

### Import Media/File

1. User explicitly chooses import.
2. App requests only the permission required by that action.
3. Input type/size/source is validated.
4. User previews and confirms where practical.
5. App copies data into durable app-owned storage.
6. Failure leaves no half-created item or abandoned temporary file.

### Search

1. User enters a query.
2. App searches title, body, filename, tags, and safe metadata.
3. Results remain scoped to the selected workspace/filter.
4. No-results and clear-query states are explicit.

### Delete

1. User requests deletion.
2. App shows the affected item/workspace and attachment consequence.
3. User confirms.
4. Database records, durable files, and search index state are reconciled.
5. Failure is surfaced; partial deletion is not silently reported as success.

## Required Product States

Every relevant screen/operation must define:

- idle;
- empty;
- editing;
- saving;
- importing;
- completed;
- cancelled;
- permission denied/restricted/revoked;
- invalid input;
- unsupported type;
- corrupt file;
- missing durable file;
- insufficient storage;
- persistence failure;
- export/share failure.

Iteration 1 must not contain a generic permanent loading spinner without a
defined owner, cancellation behavior, or failure path.

## Privacy And Data Lifecycle

- All content stays local in Iteration 1.
- No analytics or logging of user content.
- No backend, account, provider credential, or network upload.
- Imported content is untrusted and validated before durable storage.
- Durable user files use an explicit file-protection and backup policy.
- Regenerable cache is excluded from backup and can be cleared.
- Temporary picker/provider files are copied and released correctly.
- Image metadata such as location is not retained unless product behavior
  explicitly needs it.
- Delete item deletes owned attachment files when no remaining owner exists.
- Delete workspace clearly states whether all contained items will be deleted.
- Delete all data removes SwiftData records, app-owned files, cache, and index.

## Architecture Contract

- SwiftUI application.
- MVVM for screen-level state with explicit intent methods.
- SwiftUI native state for local visual interaction state.
- `@MainActor` only for UI-facing state owners.
- SwiftData for app-owned metadata/relationships.
- App-owned files for images, documents, PDFs, and audio.
- Views do not perform persistence or file I/O.
- Repeated rows receive narrow immutable state and callbacks.
- No generic `send(_:)` or action enum MVVM API.
- No Use Case, repository protocol, factory, adapter, or extra package without a
  concrete current boundary problem.
- Coordinator/router and app composition are required baseline architecture, not
  optional abstractions to defer.
- One app target at project creation.
- No source-project product model or branded reusable dependency.

## Design Direction

- Designed in-project as a native SwiftUI MVP; Figma is not required.
- System-first interaction patterns.
- Semantic tokens rather than one-off colors.
- Light and dark appearance.
- Dynamic Type and VoiceOver from the first real screen.
- Content-first layout; decorative effects are secondary.
- No speculative social, account, collaboration, or cloud UI.

## Accessibility And Localization

- User-visible copy is localizable from the first feature.
- Initial language set may start with English plus Russian when implementation
  begins; exact localization scope is confirmed per UI block.
- VoiceOver labels and focus behavior are required for actionable controls.
- Dynamic Type must not hide primary actions or truncate critical errors.
- Permission and destructive-confirmation copy must remain understandable
  without relying on color alone.

## Observability Without User-Content Logging

Iteration 1 may keep local debug-only sanitized operational metadata such as:

- operation category;
- duration;
- success/cancel/failure category;
- content type;
- file size class;
- error code.

It must not record note bodies, filenames containing private information, URLs,
document contents, audio, images, or raw file paths in analytics/log exports.

## Verification Policy

- Test-writing remains prohibited.
- Xcode build and manual Simulator validation are allowed when useful.
- Resource policy: do not rebuild after every cosmetic line; build after project
  configuration, persistence, file/audio integration, App Intents, and coherent
  user-flow blocks.
- Strong claims require static/build/manual evidence or an explicit remaining
  risk.
- Physical-device-only behavior remains a documented risk.

## Iteration 1 Completion Criteria

The non-AI product is complete only when the user can:

1. Create, rename, open, and delete a workspace.
2. Create and edit a text note.
3. Import and view an image.
4. Import and view a PDF/document.
5. Import and play audio.
6. Record and play audio where the available runtime permits it.
7. Add and safely open a URL reference.
8. Tag, filter, and search content deterministically.
9. Move, export/share, and delete supported content.
10. Relaunch without losing valid content.
11. Recover from permission, corrupt-file, missing-file, and storage failures.
12. Use basic non-AI Shortcuts/App Intents and Spotlight flows.
13. Export or delete all local data.
14. Use the app offline with no cloud dependency.
15. Use core flows with accessibility and localized UI foundations.

## Explicit Non-Goals For Iteration 1

- Any AI/ML inference or fake AI result.
- OCR, transcription, translation, classification, embeddings, or semantic RAG.
- Foundation Models, Core ML, Create ML, or Core AI integration.
- Cloud provider/backend/account/authentication/sync.
- AI result/provenance persistence schema.
- Realtime voice assistant.
- Image generation.
- Autonomous agent/tool loop.
- Video content.
- Widgets, share extension, collaboration, or multi-device sync unless separately
  approved later.

## Open Questions

No question currently blocks Block 1.18 audio-recording work. Content-specific limits,
exact copy, and interaction details are intentionally decided immediately before
their corresponding small implementation block rather than guessed now.
