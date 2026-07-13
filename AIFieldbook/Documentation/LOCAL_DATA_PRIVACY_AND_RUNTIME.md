# AI Fieldbook Local Data, Privacy, And Runtime Contract

## Scope

This document is app-specific to AI Fieldbook Iteration 1. It does not define reusable Zenflow rules.

## Local-Only Contract

- AI Fieldbook has no account, backend, analytics, or cloud processing in Iteration 1.
- User-created content is stored in app-owned local SwiftData records and Application Support files.
- Imported files are copied into app-owned storage; temporary picker/provider URLs are not persisted.
- Generated exports are user-initiated and temporary.

## Spotlight Contract

Core Spotlight can expose local titles, subtitles, tags, and workspace names through system search. Because Iteration 1 has no explicit opt-in privacy control, Spotlight indexing is disabled by default.

Delete-all flows still clear Spotlight indexes to remove data created by older builds or future opt-in sessions.

Search and future Spotlight snapshots are read through `FieldbookSearchIndex`, a background SwiftData model actor. UI state remains main-actor owned, but growing read-only queries do not require main-context repository loops.

## File Backup Contract

Iteration 1 has no approved cloud data path. App-owned content, staging files, and generated exports are marked excluded from system backup. This intentionally favors local-only privacy over device-to-device cloud restore.

If the product later needs backup/restore, that must be a separate app-specific decision with explicit user-facing privacy copy.

Preparing a new export removes older generated exports first. Exports are temporary user-share artifacts, not durable secondary storage.

Delete-all is allowed to ignore already-missing app-owned files while still deleting SwiftData records, generated exports, runtime detail caches, navigation stacks, and Spotlight indexes. This prevents stale or previously-corrupted file state from blocking a full local reset.

## Runtime Ownership

- `AppComposition` owns long-lived services, repositories, feature state owners, and modal state.
- `FieldbookRepository` owns SwiftData main-context access and maps records to UI/domain state.
- `FieldbookSearchIndex` owns background SwiftData read snapshots for search/indexing.
- `AppFileStore` owns app-managed files, import validation, staged deletion, cleanup, and exports.
- `SpotlightIndexService` owns optional system search indexing and clearing.

## Iteration Boundary

App Intents and AI features remain out of Iteration 1. They begin only after the manual Iteration 1 acceptance gate is accepted.
