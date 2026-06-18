# AppEnvironment Package Contract

## Purpose

`AppEnvironment` provides a product-independent environment snapshot for iOS/macOS/tvOS/watchOS applications.

It is a mechanism package. It is not an app configuration system, a feature-flag system, a session manager or a networking environment router.

## Standalone rules

This package must remain 100% single-folder standalone:

- no `.package(path: "../...")` dependencies;
- no remote package dependencies;
- no imports of sibling SDK packages;
- all sources, tests, scripts and DocC live inside this folder;
- DocC is source-owned under `Sources/AppEnvironment/Documentation.docc/`;
- verification must use a worktree-local scratch path and must not leave `.build` or `.swiftpm` inside this folder.

## Public API ownership

The package owns:

- `EnvironmentKind`;
- `BuildConfiguration`;
- `AppBuildInfo`;
- `AppRuntimeFlags`;
- `AppLocaleContext`;
- `AppEnvironmentSnapshot`;
- provider protocols and default/static providers;
- privacy-safe environment diagnostics.

## Privacy and security

The package must not expose or store:

- full `ProcessInfo.processInfo.environment`;
- full `ProcessInfo.processInfo.arguments`;
- full `Bundle.infoDictionary`;
- credentials, tokens, cookies or backend secrets;
- raw diagnostic dumps.

Only allowlisted build/runtime fields may enter `AppEnvironmentSnapshot`.

## Concurrency

All public value types must be `Sendable`.

Provider protocols are `Sendable` and async-compatible, even if current implementations are lightweight.

## Multi-target policy

A future multi-target split is allowed only if every target remains inside this package folder and no sibling dependency is introduced.

## Integration policy

Examples of integrations that must not live in this root package:

- `AppEnvironment + AppNetworking` base URL selection;
- `AppEnvironment + AppAnalytics` environment attributes;
- `AppEnvironment + AppConfiguration` bootstrap;
- `AppEnvironment + AppDiagnostics` provider registration.

Those belong in optional helper packages or app composition code.
