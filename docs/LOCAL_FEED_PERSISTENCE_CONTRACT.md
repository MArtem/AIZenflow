# Local Feed Persistence Contract

## Purpose
Product/runtime contract for locally created feed cards and their media assets.

This document prevents temporary composer/picker logic from leaking into the published feed runtime.

## Core Rule
A card published from the app composer must be self-contained enough to survive app restart and offline usage.

## Active Runtime
- Active persistence runtime is `SwiftData`.
- `UserDefaults` must not be used for feed-card persistence.
- `Core Data` is fallback-only historical material, not the active design direction.

## Published Card Persistence
A published feed card must persist:
- card id
- channel id
- created date
- card kind: `text`, `photo`, `video`, `audio`, `pdf`
- ordered text content
- source text and optional source URL
- media metadata
- interaction state: like, comments count, display mode
- durable file references for media assets

## Media Asset Persistence
Media chosen through picker/document picker/share extension must be copied into an app-owned durable location before or during publish.

Do not persist references that depend on:
- temporary picker URLs
- external file-provider availability
- transient security-scoped access after app relaunch

A persisted feed card should be able to render after restart without requiring the original picker/document provider to still be available.

## Local-First Display Rule
Feed display should prefer the local persisted snapshot for locally created cards.

Future backend/API sync should be additive:
- local create writes DB first or queues mutation
- backend upload/sync may update remote status later
- offline feed uses DB snapshot
- remote refresh must not destroy local-only cards or local interaction state

## Sync State Direction
Backend sync is expected and should be designed as a real product-grade flow, not as an afterthought.

The local feed schema should be ready to represent sync state when backend integration arrives.
Expected state concepts may include:
- `localOnly`: created locally and not scheduled/uploaded yet
- `syncPending`: queued for upload/sync
- `syncing`: currently being sent or reconciled
- `synced`: accepted by backend and linked to remote identity/version
- `syncFailed`: failed but retained locally with retry/error context

Do not hardcode this exact enum until the backend contract is known, but avoid designs that would make these states hard to add.

Persisted cards should be able to carry future sync metadata such as:
- remote id
- remote version/revision
- last synced date
- pending mutation id
- last sync error category/message
- conflict marker or resolution policy

## Recommended Sync Shape
For future backend integration, prefer this direction:
1. Persist feed card and durable media first.
2. Create an outbound mutation record for backend sync.
3. Let `SyncCore` own mutation queue mechanics, retry, and status transitions.
4. Keep app-specific card mapping, media upload semantics, endpoint payloads, and UI policy in `TchopApp`.
5. Merge backend responses into the same feed card record instead of replacing it with a separate remote-only object.
6. Preserve local interaction state unless backend explicitly owns and returns a newer authoritative value.
7. Treat media upload as part of sync: upload durable local files, then persist remote asset references when accepted.

## Sync Ownership
- Generic sync mechanics belong in `SyncCore`.
- App-specific feed/card mapping, schema, endpoint semantics, and UI-facing policy stay in `TchopApp`.

## Feed Card Runtime Contract
Locally created cards and future API cards should converge toward the same feed-card semantics:
- same card kinds
- same text-field order
- same media metadata rules
- same action toolbar semantics where supported

Avoid permanent split-brain behavior such as separate UI/action logic for “local” vs “remote” unless the product explicitly requires different behavior.
