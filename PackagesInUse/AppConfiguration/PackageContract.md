# AppConfiguration Package Contract

## Single-folder standalone status

This folder is a complete Swift Package. It can be copied by itself into another repository and opened/tested as a Swift Package without copying sibling packages from this repository.

Required contents:

```text
AppConfiguration/
  Package.swift
  README.md
  PackageContract.md
  Sources/
  Tests/
```

## Responsibility

Standalone remote/local configuration snapshot manager. It owns generic configuration mechanics and sanitized runtime metadata, not product-specific payloads.

## Dependency rule

This package must not contain sibling path dependencies such as `.package(path: "../AppNetworking")`. Source and test files must not import modules owned by sibling root packages.

## Composition rule

If this package needs to be composed with another root package, that composition must live in a host app target or in an optional integration helper package/file under `Packages/IntegrationHelpers`.

## Verification

From this folder, run:

```bash
swift test
```

From the repository package workspace, run:

```bash
./Packages/verify_single_folder_standalone.sh
./Packages/verify_foundation_only_packages.sh
# On macOS/Xcode:
./Packages/verify_apple_packages_macos.sh
./Packages/verify_strict_concurrency_macos.sh
```
