# AppGlassUI Package Contract

## Single-folder standalone status

This folder is a complete Swift Package. It can be copied by itself into another repository and opened/tested as a Swift Package without copying sibling packages from this repository.

Required contents:

```text
AppGlassUI/
  Package.swift
  README.md
  PackageContract.md
  Sources/
  Tests/
  Scripts/verify_package.sh
```

## Responsibility

Reusable Liquid Glass availability/fallback mechanics for SwiftUI chrome.

## Dependency rule

This package must not contain sibling path dependencies such as `.package(path: "../AppBranding")`. Host apps pass colors/styles directly or compose with branding packages outside this root package.

## Composition rule

If this package needs to be composed with another root package, that composition must live in a host app target or in an optional integration helper package/file under `Packages/IntegrationHelpers`.

## Verification

From this folder, run:

```bash
./Scripts/verify_package.sh
```
