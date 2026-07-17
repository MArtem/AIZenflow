# Xcode Build, Binary, And Supply Chain

## Load When
Use for targets, schemes, build settings, xcconfig, compiler/linker errors, SwiftPM, modules, binary frameworks, XCFrameworks, signing inputs, CI reproducibility, dependency security, licensing, or build performance.

## Build Model
An Xcode build is a dependency graph of targets, phases, scripts, generated files, resources, compiler invocations, link steps, signing, and packaging. Workspace UI settings are not the contract by themselves; inspect effective settings for the exact target/configuration/destination.

## Configuration
- Keep environment differences in versioned non-secret configuration and local secret injection.
- Prefer layered `.xcconfig` files when settings are shared or need reviewable inheritance.
- Inspect `$(inherited)` and precedence across project, target, xcconfig, command line, and environment.
- Do not encode production behavior through `#if DEBUG` when a runtime environment/feature decision is required.
- Keep bundle IDs, entitlements, capabilities, URL schemes, app groups, and signing consistent per configuration.

## Targets And Build Phases
- Every source/resource has intentional target membership.
- Script phases declare inputs/outputs or explain why they must always run.
- Scripts fail on meaningful errors, avoid secrets in logs, and write only approved derived paths.
- Generated code has a reproducible generator/version and does not silently overwrite human source.
- Embed/sign only what the product target requires.

## Modules And Linking
- A module boundary is a compile-time/API boundary, not automatically an architecture boundary.
- Avoid cyclic dependencies and umbrella modules that erase ownership.
- Distinguish static and dynamic linking, resource bundles, duplicate symbols, runtime search paths, and app-extension-safe APIs.
- Public binary distribution requires module stability and a compatible library-evolution strategy; source packages have different compatibility economics.
- Inspect architectures and platform slices in XCFrameworks; Simulator and device slices are not interchangeable.

## SwiftPM And Dependencies
- Pin or constrain versions deliberately and commit resolution according to repository policy.
- Review transitive dependencies, products, plugins, macros, binary targets, and build scripts.
- Prefer source dependencies when auditability and compatibility matter, unless binary distribution has a justified benefit.
- A package update is code adoption: review release notes, API/behavior changes, privacy manifests, minimum platforms, licenses, and security advisories.
- Do not add a dependency for a small stable behavior available in the standard library or platform.

## Supply Chain
Maintain an inventory with package name, source, version/revision, owner, license, transitive dependencies, update policy, and security/privacy classification. Verify checksums/signatures where supported. Treat plugins, macros, binary frameworks, and install scripts as executable code.

For regulated or higher-risk products, generate or maintain an SBOM in an accepted format and define vulnerability intake, severity, patch timing, exception, and removal procedures. License obligations and export controls require owner review; an automated scanner is evidence, not legal approval.

## Binary And Runtime Diagnosis
- Undefined symbols: inspect target membership, product linkage, architecture, visibility, and conditional compilation.
- Duplicate symbols: inspect duplicated source/static products and generated code.
- Runtime load failure: inspect embedded frameworks, signatures, install names, runpaths, platform/architecture, and minimum OS.
- Swift interface failure: inspect compiler compatibility, library evolution, generated interface, and dependency version.
- Resource failure: inspect bundle ownership and package resource declaration rather than assuming `Bundle.main`.

## Reproducibility And CI
- Pin Xcode/toolchain and record destination/configuration.
- Isolate DerivedData and package caches within approved paths.
- Avoid undeclared reliance on developer-machine state, global tools, login keychains, or mutable network downloads.
- Cache only inputs whose key includes all compatibility dimensions; provide a clean-cache fallback.
- Preserve logs, result bundles, archives, and dSYMs according to retention/privacy policy.

## Build Performance
Measure clean and incremental builds separately. Inspect type-check hotspots, dependency fan-out, generated code, macros, script phases, module invalidation, and linker time. Modularization that adds boundaries can improve parallelism or worsen overhead; decide from dependency graph and measurements.

## Evidence
- Clean and incremental build for intended targets/configurations/destinations.
- Archive/export when distribution is claimed.
- Effective build-setting capture with secrets redacted.
- Dependency resolution from a clean approved cache.
- Architecture/slice, embedding, signature, resource, and extension-safety checks.
- License/security inventory and privacy manifest review for dependencies.
- Before/after build metrics for performance claims.

## Primary Sources
- [Xcode documentation](https://developer.apple.com/documentation/xcode)
- [Xcode release notes](https://developer.apple.com/documentation/xcode-release-notes)
- [Swift Package Manager](https://www.swift.org/documentation/package-manager/)
- [Distributing binary frameworks as Swift packages](https://developer.apple.com/documentation/xcode/distributing-binary-frameworks-as-swift-packages)

Review after Xcode/SwiftPM releases, dependency or plugin adoption, binary distribution changes, signing changes, or supply-chain advisories.
