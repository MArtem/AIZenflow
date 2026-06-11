# AppNetworking Package Contract

## Single-folder standalone status

This folder is a complete Swift Package. It can be copied by itself into another repository and opened/tested as a Swift Package without copying sibling packages from this repository.

Required contents:

```text
AppNetworking/
  Package.swift
  README.md
  PackageContract.md
  Sources/
  Tests/
```

## Responsibility

Standalone networking core package. It owns request/response, retry, interceptors, offline queue, and rich HTTP failures without importing analytics/errors packages.

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
