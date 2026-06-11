# Packages

`./Packages` no longer contains runtime SwiftPM packages for `TchopApp`.

## Current role

This folder is now reserved for reusable SDK/package creation documentation, templates, and optional copy-file integration helpers:

- `./Packages/SDKCreation`: templates, scripts, and docs for creating future standalone package folders.
- `./Packages/Docs`: archived package-hardening reports and SDK baseline notes.
- `./Packages/IntegrationHelpers/CopyFiles`: optional cross-package helper source files that can be copied into an app/integration target when needed.

## Active app package code

The app compiles package source directly from `./PackagesInUse` to reduce local SwiftPM build/cache growth while this worktree is used as the package-library testbed.

- `./PackagesInUse`: source-only active subset used by `TchopApp`, `TchopShareExtension`, and `TchopWidgetsExtension`.
- `./PackagesForReuse`: complete source-only vault of all reviewed current/future reusable packages.

## Rules

- Do not connect `./Packages` to app targets.
- Do not restore active package folders here unless the project intentionally returns to real SwiftPM package linkage.
- Do not store generated artifacts here: `.build`, `.swiftpm`, `DerivedData`, `xcuserdata`, logs, or temporary build products.
- Any build/cache output must stay under `/Users/Artem/.zenflow/worktrees/`.

## Future SwiftPM use

Each package preserved under `./PackagesForReuse` and `./PackagesInUse` still keeps its `Package.swift`, README, contract docs, tests, DocC, and verify scripts. A future project can copy one package folder and connect it through SwiftPM when disk/build-cache cost is acceptable.
