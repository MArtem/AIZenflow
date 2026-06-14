# AppBackgroundTasks Package Contract

## Purpose

`AppBackgroundTasks` provides product-independent background task primitives for Swift applications.

It is not a sync package, networking package, lifecycle package, analytics package, logging package, session package or diagnostics exporter.

## Standalone rules

This package must remain 100% single-folder standalone:

- no `.package(path: "../...")` dependencies;
- no remote package dependencies;
- no imports of sibling SDK packages;
- all sources, tests, scripts and DocC live inside this folder;
- DocC is source-owned under `Sources/AppBackgroundTasks/Documentation.docc/`;
- verification must use a worktree-local scratch path outside this package folder;
- verification must not leave `.build`, `.swiftpm`, `Package.resolved` or archive artifacts inside this folder.

## Public API ownership

The package owns:

- background task identifiers;
- background task kinds;
- task registration models;
- task request models;
- task execution context;
- task result and sanitized failure models;
- manual scheduler;
- default manager for deterministic host-app execution;
- privacy-safe diagnostics;
- native request factory behind compile guards.

## Privacy and security

The package must not expose:

- user identifiers;
- auth/session tokens;
- cookies;
- backend secrets;
- full file-system paths;
- raw notification payloads;
- raw deep link URLs;
- product-specific job names in diagnostics.

Identifiers may be used for scheduling, but default descriptions and diagnostics must avoid exposing raw identifiers unless the host app explicitly reads `rawValue`.

## Concurrency

All public value types must be `Sendable`.

Mutable scheduling state is isolated behind actors. The package must not perform hidden blocking native scheduler operations on a caller executor. Native submission belongs to host-app/integration boundaries.

## Multi-target policy

A future multi-target split is allowed only if every target remains inside this package folder and no sibling dependency is introduced.

## Integration policy

Examples of integrations that must not live in this root package:

- `AppBackgroundTasks + AppLifecycle` scheduling after foreground/background events;
- `AppBackgroundTasks + AppSync` background sync job execution;
- `AppBackgroundTasks + AppLogging` task log enrichment;
- `AppBackgroundTasks + AppAnalytics` task metrics;
- `AppBackgroundTasks + AppConnectivity` network-aware scheduling policy;
- `AppBackgroundTasks + AppDiagnostics` provider registration.

Those belong in optional helper packages or host app composition code.


## Current hardening notes

- Failure diagnostic codes are sanitized before they can appear in errors or diagnostics.
- Pending requests must not be removed when execution cannot start because no handler is registered.
- Compile guards must account for platform availability, not only `canImport(BackgroundTasks)`.
