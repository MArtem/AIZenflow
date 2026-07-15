# AI Fieldbook Architecture Decisions

## ADR-001 — Independent Single-Target iOS Application

### Status

Accepted for Iteration 1 planning.

### Context

AI Fieldbook is a new internal learning product and must remain independent from
any source-project product models, targets, navigation, persistence, and feature
policy.
Xcode 26.5 and iOS Simulator SDK/runtime 26.5 are available; the approved
deployment target is iOS 26.0.

### Options Considered

1. Add AI Fieldbook features to an existing app.
2. Create a new independent app with one target.
3. Create stable/experimental targets immediately.

### Decision

Create one independent SwiftUI iOS app target in a dedicated project directory
inside the current worktree. Do not create a second target until an actual SDK or
beta-isolation constraint proves it necessary.

### Consequences

- No source-project product dependency.
- Smaller initial project and build graph.
- Future iOS 27 features require an explicit revisit.

### Rollback

Before runtime data exists, project creation can be reverted by removing only the
new independent project directory. No existing app target is affected.

### Revisit Trigger

- Xcode 27 beta integration cannot compile safely in the same target.
- A separate macOS/iPad-specific product becomes an approved requirement.

### Owner

AI Fieldbook app composition.

## ADR-002 — SwiftUI Native State Plus MVVM, App Composition, And Coordinator Navigation

### Status

Accepted for Iteration 1 planning.

### Context

The product contains navigation, editable forms, persistence, file imports, and
permission/error states. Pure view-local state is insufficient for all screens,
but a reducer framework or multilayer Clean architecture is not required by the
current feature set.

### Options Considered

1. SwiftUI view-local state for the entire app.
2. MVVM with explicit intent methods.
3. TCA/UDF with generic actions.
4. Clean/VIPER-style layers for every feature.

### Decision

Use SwiftUI native state for local visual interactions and MVVM for screen-level
product state. ViewModels expose explicit methods such as `saveTapped()`,
`workspaceSelected(id:)`, `searchQueryChanged(_:)`, and `deleteConfirmed()`.

The app composition root owns the repository, durable file store, screen-level
state owners, and their lifetime. Feature views receive an existing model and
callbacks; they do not construct repositories or ViewModels in `init`.

One app coordinator owns the selected tab and one typed `TabRouter` per tab.
Routes carry stable value identifiers rather than models or repositories. The
app owns product routes and destination rendering; the reviewed source-only
`AppNavigation` package supplies only the generic tab-router primitive.

Use Cases, protocols, adapters, component ViewModels, or additional packages are
added only for a demonstrated boundary/lifecycle need. Coordinator/router,
composition root, feature state ownership, and physical project structure are
not optional foundations and are present from the first implementation block.

### Consequences

- Public behavior stays readable and searchable.
- No generic `send(_:)` dispatcher.
- Repeated rows receive narrow immutable view state and callbacks.
- File/persistence operations stay outside SwiftUI `body`.
- Cross-tab opening and deep links have one deterministic owner.
- Every screen model has one explicit composition-time owner.

### Rollback

Local view state can be promoted or demoted without changing the product data
model. A future architecture change requires a new ADR.

### Revisit Trigger

- Reducer/effect requirements become concrete and repeated.
- A flow requires child coordinators or restorable navigation snapshots.
- A component gains a real independent async/resource lifecycle.

### Owner

AI Fieldbook presentation/application composition.

## ADR-003 — SwiftData Metadata Plus App-Owned Durable Files

### Status

Accepted for Iteration 1 planning.

### Context

The app stores structured workspaces/items/tags and potentially large images,
PDFs, documents, and audio. Persisting large binaries directly in the metadata
store or retaining temporary picker URLs would create lifecycle and performance
risks.

### Options Considered

1. Store all content as SwiftData binary attributes.
2. Store all data in custom JSON/files.
3. Store structured metadata in SwiftData and large content in app-owned files.

### Decision

Use SwiftData for app-owned structured metadata and relationships. Store imported
media/documents/audio as durable files under app-owned storage and persist stable
relative references plus integrity/metadata fields.

SwiftData schema and file layout are app policy. Reusable file-storage mechanisms
may be adopted only after neutral-contract review; direct use is acceptable if it
is simpler and safe for the first requirement.

### Invariants

- Temporary picker/provider URLs are not durable references.
- A successful item save never points at an incomplete file.
- Failed import cleans incomplete files/records.
- Delete reconciles record, owned file, cache, and search index.
- User content is not silently backed up or excluded without an explicit policy.

### Migration Plan

The initial schema starts at version 1. Every schema/file-layout change after
data exists requires an explicit compatibility and rollback decision.

### Rollback

Before launch data exists, schema/file layout can be recreated. After user data
exists, destructive recreation is not an assumed option.

### Revisit Trigger

- Sync/backend is approved.
- App Group/share extension is approved.
- Storage volume proves SwiftData/file layout insufficient.

### Owner

AI Fieldbook app persistence and file policy.

## ADR-004 — Strict Separation Between Non-AI And AI Iterations

### Status

Accepted.

### Context

The learning goal requires understanding both normal product engineering and AI
integration. Adding AI infrastructure before a complete user product would hide
whether AI solves a real user problem and would encourage speculative routing,
providers, prompts, schemas, and mocks.

### Options Considered

1. Build AI and product features together from the first screen.
2. Add placeholder provider interfaces during Iteration 1.
3. Complete the non-AI product, then add AI one capability at a time.

### Decision

Iteration 1 contains no AI inference, AI provider abstraction, model router,
prompt registry, AI result schema, or fake AI response. Iteration 2 begins only
after the non-AI completion gate is accepted.

Spotlight and deep links remain in Iteration 1 as system discovery/navigation
mechanisms. By explicit user sequencing decision, all App Intents — including
non-AI intents — begin in Iteration 2 together with the system/AI integration
track. Iteration 1 contains no App Intents target metadata or intent types.

### Consequences

- Iteration 1 remains independently useful and testable manually.
- AI features attach to proven data and user flows.
- No silent local-to-cloud fallback or unused provider layer exists.

### Rollback

Not applicable; this is a sequencing rule.

### Revisit Trigger

- The user explicitly changes the iteration boundary.

### Owner

AI Fieldbook product roadmap.

## ADR-005 — Local-Only Iteration 1 And Deferred Cloud

### Status

Accepted.

### Context

No backend, provider budget, cloud credentials, or consent to transmit private
content is approved.

### Decision

Iteration 1 performs no content upload and has no account/backend/cloud runtime.
Iteration 2 starts with available local/system capabilities. Cloud work remains a
separate gated track requiring a backend/security/privacy ADR, provider/budget,
explicit consent, and current official API verification.

### Consequences

- No provider secret exists in the app.
- `local-only` is accurate in Iteration 1.
- Cloud UI cannot pretend to be configured.

### Revisit Trigger

- User approves backend, provider, budget, and data classes allowed for cloud.

### Owner

AI Fieldbook privacy and routing policy.

## ADR-006 — Crash-Recoverable Local File Transactions

### Status

Accepted on 2026-07-15 for the Iteration 1 remediation pass.

### Context

SwiftData records and app-owned files cannot participate in one native atomic transaction.
Moving a file into temporary deletion storage and then mutating SwiftData is rollbackable during
normal execution, but process termination between those steps can otherwise leave a record
without its file or cause startup cleanup to destroy the only recoverable copy.

### Decision

- Every destructive file batch writes a versioned manifest before moving any content.
- SwiftData remains the source of truth during relaunch reconciliation: referenced content is
  restored and content whose record deletion committed is finalized.
- Invalid, conflicting, or incomplete recovery state is preserved and surfaced; startup must
  never blanket-delete transactional staging.
- New imported files embed a streaming SHA-256 digest in their opaque app-owned filename and are
  verified when resolved. Existing legacy filenames remain readable without a destructive
  migration.
- Private content, manifests, drafts, and exports use complete file protection and remain
  excluded from backup under the current local-only contract.

### Consequences

- Delete flows may report incomplete cleanup instead of claiming success after a rollback or
  finalization failure.
- Interrupted transactions can be reconciled after relaunch without a database schema change.
- Integrity verification adds bounded off-main file I/O when newly imported content is opened.
- Runtime crash-injection and locked-device verification remain mandatory before declaring the
  policy production-proven.

### Rollback

The manifest reader and hashed-filename support must remain compatible with data already written.
Future replacement may stop creating new manifests, but it must reconcile existing batches and
continue reading both legacy and digest-bearing filenames.

### Revisit Trigger

- A backend/sync layer changes the source of truth.
- App Group or extension access is approved.
- Runtime evidence shows integrity hashing or complete protection conflicts with an approved
  background workflow.

### Owner

AI Fieldbook persistence and local file lifecycle.
