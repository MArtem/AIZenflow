# App Infrastructure SDK — Iteration 00

This archive is the **baseline standard** for building a large set of app-independent iOS infrastructure packages.

Iteration 00 created the reusable **package template, rules, policies, verification scripts, and roadmap** that every future package must follow. The current repository has since adopted production runtime packages through `./PackagesForReuse/AppConnectivity`.

## Goal

Every root package created in future iterations must be:

- **single-folder standalone**;
- copyable into any new project as one Swift Package folder;
- free from sibling path dependencies;
- free from app-specific product logic, routes, screens, strings, and features;
- testable in isolation;
- documented with a package contract;
- safe by default with respect to privacy, telemetry, and concurrency.

## Folder structure

```text
InfrastructureSDK_Iteration00/
├── Catalog/
├── Sources/<Module>/Documentation.docc/
├── Scripts/
├── Templates/
│   ├── IntegrationHelperTemplate/
│   └── PackageTemplate/
└── README.md
```

## How to use this baseline

For every new package:

1. Copy `Templates/PackageTemplate`.
2. Replace all `{{PackageName}}` placeholders.
3. Fill in `PackageContract.md` before writing implementation.
4. Add tests before considering the package complete.
5. Run `Scripts/verify_package_structure.sh <PackagePath>`.
6. Run the package-local `Scripts/verify_package.sh`.
7. If the package needs cross-package integration, create an optional helper using `Templates/IntegrationHelperTemplate`.

## Current roadmap

The planned SDK contains 50 package iterations plus final hardening. See:

```text
Catalog/SDK_PACKAGE_ROADMAP_50.md
```

## Status

```text
Iteration: 00
Status: SDK standard/template created
Production packages added in this baseline: 5
Latest production package: AppConnectivity
Next planned iteration: AppPermissions or another user-approved infrastructure package
```


## source-app adaptation note

This baseline was adopted from `InfrastructureSDK_Iteration00.zip` and hardened to match the current repository contract:

- DocC lives under `Sources/<Module>/Documentation.docc/` so docs travel with the source target.
- Template verification uses temporary or externally supplied SwiftPM build paths and cleans package-local generated state.
- Creation scripts validate Swift identifier names before writing files.
- Structure verification checks target folders, source DocC, unresolved placeholders, sibling dependencies, unsafe flags, and archive hygiene.


## Multi-target note

Multi-target packages are allowed when the targets are inside the same package folder and remain app-independent. The standalone verifier requires at least one source target, at least one test target, and source-owned DocC, but it does not require every package to have exactly one target named after the package.

## Iteration 01 note

`./PackagesForReuse/AppSecureStorage` was adopted as the secure-storage runtime package after additional local hardening:

- Keychain writes now prefer an in-place update for existing values and reserve delete/add for synchronizable-scope changes.
- Package verification fails if compiler warnings are emitted.
- The package is indexed in the active package inventory and root package verification scripts.

## Iteration 03 note

`./PackagesForReuse/AppFeatureFlags` was adopted as the feature-flag runtime package after additional local hardening:

- Snapshot validation rejects empty keys, dictionary/payload key mismatch, and invalid rollout percentages.
- UserDefaults-backed snapshot and override stores were added so the package is useful without a sibling configuration package.
- Package verification fails if compiler warnings are emitted.
- The package is indexed in the active package inventory and root package verification scripts.

## Iteration 04 note

`./PackagesForReuse/AppLogging` was adopted as the structured logging package after additional local hardening:

- Swift tools version was normalized to 5.9 for consistency with the current standalone package baseline while keeping strict-concurrency verification in scripts.
- Package verification fails if compiler warnings are emitted.
- Documentation now clarifies that `NoopLogger` is the safe default, `MemoryLogger` is primarily for tests/local diagnostics, and public messages require explicit host-app privacy classification.
- The package is indexed in the active package inventory and root package verification scripts.

## Iteration 05 note

`./PackagesForReuse/AppObservability` was adopted as the observability package after additional local hardening:

- Swift tools version was normalized to 5.9 for consistency with the current standalone package baseline while keeping strict-concurrency verification in scripts.
- URL redaction now removes query/fragment data from absolute URLs, relative paths, and scheme-less URL strings.
- `measure(...)` records `CancellationError` as `.cancelled`.
- `ObservabilitySpan.end(...)` is single-shot so duplicate end calls do not emit duplicate events.
- Package verification fails if compiler warnings are emitted and must not create package-local SwiftPM artifacts.
- Documentation now clarifies privacy, cancellation, span lifecycle, and caller-owned correlation policy.
- The package is indexed in the active package inventory and root package verification scripts.

## Iteration 06 note

`./PackagesForReuse/AppConnectivity` was adopted as the connectivity package after additional local hardening:

- Swift tools version was normalized to 5.9 for consistency with the current standalone package baseline while keeping strict-concurrency verification in scripts.
- Native `NetworkPathConnectivityMonitor.start()` is idempotent while active and `stop()` is documented as terminal because `NWPathMonitor` cancellation is terminal.
- Package-owned tests cover native monitor start/stop idempotency on Apple platforms, manual/static monitors, transition streams, waiter behavior, cost policy, and privacy-safe diagnostics.
- Package verification fails if compiler warnings are emitted and must not create package-local SwiftPM artifacts.
- The package is indexed in the active package inventory and root package verification scripts.
