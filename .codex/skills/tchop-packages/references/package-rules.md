# Package Rules

## Foundation Rule
- Reusable packages/managers are the foundation.
- App code adapts to packages.
- Generic behavior belongs in the package.
- Project-specific behavior belongs in the app.

## What Must Not Happen
- Do not add decorative protocols or facades over a good package surface.
- Do not duplicate sync state-machine logic in repositories if `SyncCore` can own it.
- Do not let rollback-only Core Data material drive active runtime design.

## Active Runtime Assumptions
- `SwiftData` is active.
- `Core Data` is fallback-only material.
- `SyncCore` is active and should absorb reusable sync behavior.

## App-Layer Ownership
Keep these in `TchopApp`:
- endpoint semantics
- DTO/app model mapping
- local schema application
- routing/deep-link semantics
- feature-specific UX policy
