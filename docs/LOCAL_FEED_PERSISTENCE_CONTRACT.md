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
A published local card must persist:
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
