# Package Usage in TchopApp

## Current integration mode

`TchopApp` currently uses reusable infrastructure package code in **source-only local mode**.

This is intentional. The worktree is used to build a reusable package library, but connecting dozens of packages through SwiftPM creates large `.build`, `.swiftpm`, cloned package, and DerivedData artifacts. To control disk usage, only source files from active packages are compiled into app targets.

## Folder roles

- `./PackagesForReuse`: complete source-only package library/vault. Every reviewed package goes here.
- `./PackagesInUse`: active source-only subset compiled into this app.
- `./Packages`: SDK/package creation documentation, templates, reports, and optional copy-file helpers only.

## Runtime target ownership

- `TchopApp` compiles the active app package subset from `./PackagesInUse`.
- `TchopShareExtension` compiles only share-relevant package source from `./PackagesInUse`.
- `TchopWidgetsExtension` compiles only widget/localization package source from `./PackagesInUse`.
- Package source is not linked as SwiftPM products in this worktree.

## When to use package code

Use package mechanics instead of app-local duplicated code when the package surface directly fits the app need:

- networking/request/retry/error primitives
- app-facing error taxonomy/mapping helpers
- localization lookup mechanics
- brand/theme token mechanics
- Liquid Glass availability/fallback mechanics
- widget snapshot storage mechanics
- share-extension import/app-group storage mechanics
- push registration/notification forwarding mechanics
- database execution-boundary utilities
- on-device AI abstraction/fallback mechanics
- analytics event/transport mechanics

Keep product policy in app code:

- product strings and copy
- app routes and tab semantics
- endpoint-specific DTO/domain mapping
- session/auth policy
- feed/card product behavior
- schema ownership and migration decisions
- visual layout decisions and semantic roles

## Future SwiftPM use

Every package under `./PackagesForReuse` and `./PackagesInUse` keeps SwiftPM metadata and package-owned tests. A future project can copy one folder and connect it as a normal Swift Package when disk/build-cache cost is acceptable.
