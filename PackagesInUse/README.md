# PackagesInUse

## Purpose

`./PackagesInUse` contains the active source-only copies of reusable infrastructure packages currently compiled directly into `TchopApp`, share-extension and widget targets.

Use `./PackagesInUse/PACKAGE_CATALOG.md` to see what is active in the app. Use `./PackagesForReuse/PACKAGE_CATALOG.md` to choose from the full reusable vault.

## Current Counts

- Active root packages: 21
- Active helper folders: 4

## Contract

- This folder is not connected through Swift Package Manager in this project.
- Xcode compiles selected `Sources/**/*.swift` files directly into runtime targets.
- Package folders still keep SwiftPM-compatible structure so they can be copied/published later.
- Runtime targets must include only source files/resources they actually need.
- Do not store generated artifacts here: `.build`, `.swiftpm`, `build`, `DerivedData`, logs or Xcode user data.
- Build/cache/DerivedData output must stay under `/Users/Artem/.zenflow/worktrees`.

## Relationship To Other Package Folders

- `./PackagesForReuse`: complete reusable package vault.
- `./PackagesInUse`: active source-only subset compiled into this app.
- `./Packages`: SDK/package creation docs/templates only.

## Xcode Project Organization

Every active package must appear in `./TchopApp.xcodeproj/project.pbxproj` under logical group `PackagesInUse/<PackageName>`. Do not leave active package files only in recovered/unstructured Xcode references.

When adding/removing a package, update the project through `./scripts/migrate_packages_in_use_project.py` or an equivalent deterministic project edit.

## Adding A Future Package

1. Review and verify the package in `./PackagesForReuse/<PackageName>`.
2. Ensure its `README.md` has summary, solved problem, capabilities, local SwiftPM usage, remote SwiftPM usage, source-only integration notes and verification.
3. Update `./PackagesForReuse/PACKAGE_CATALOG.md`.
4. Copy/sync the package into `./PackagesInUse/<PackageName>` only if TchopApp uses it now.
5. Update `./PackagesInUse/PACKAGE_CATALOG.md` and this file.
6. Add required sources/resources through `./scripts/migrate_packages_in_use_project.py`.
7. Run `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, `./scripts/verify.sh low` and `git diff --check`.
