# PackagesForReuse

## Purpose

`./PackagesForReuse` is the complete reusable package vault. It preserves package source, tests, DocC, scripts and usage documentation without forcing every package to be connected to `TchopApp`.

Use `./PackagesForReuse/PACKAGE_CATALOG.md` as the first-stop package selector. It now includes short summaries, expanded descriptions, package ownership boundaries, and host-app responsibility notes for every package/helper. Then open the package-specific `README.md` for setup, usage examples, boundaries and verification instructions.

## Current Counts

- Root packages: 40
- Integration helper packages: 5

## Rules

- Packages here are not connected to the app by default.
- Package folders must be self-contained: `Package.swift`, `README.md`, `PackageContract.md`, `Sources`, tests where allowed, DocC/docs and verification scripts travel together.
- Do not store generated artifacts here: `.build`, `.swiftpm`, `build`, `DerivedData`, logs or Xcode user data.
- Keep generic mechanisms in packages and product-specific policy in the host app.
- Every new package must update its own README and `./PackagesForReuse/PACKAGE_CATALOG.md`.

## Main Documents

- `./PackagesForReuse/PACKAGE_CATALOG.md`: package selector and short descriptions for all packages.
- `./PackagesForReuse/CONNECTING_PACKAGES.md`: examples for connecting packages.
- `./PackagesForReuse/ADOPTION_AUDIT.md`: adoption status and rationale.

## Standard Connection Flow

1. Choose a package from `./PackagesForReuse/PACKAGE_CATALOG.md`.
2. Read that package's `README.md` and `PackageContract.md`.
3. Run package-local verification from the package folder.
4. For current TchopApp source-only mode, copy/sync the package to `./PackagesInUse/<PackageName>` and update Xcode with `./scripts/migrate_packages_in_use_project.py`.
5. For SwiftPM local mode in another project, use `.package(path:)`.
6. For SwiftPM remote mode, publish the standalone package folder as the root of its own Git repository and use `.package(url:from:)`.
7. Run host-project verification after wiring sources/resources/imports.
