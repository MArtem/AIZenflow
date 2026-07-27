# AppLifecycle Package Contract

## Purpose

`AppLifecycle` provides product-independent app lifecycle primitives for Swift applications.

It is a mechanism package. It is not a routing package, a session package, a logging package, a diagnostics exporter, a background-task package or an analytics package.

## Standalone rules

This package must remain 100% single-folder standalone:

- no `.package(path: "../...")` dependencies;
- no remote package dependencies;
- no imports of sibling SDK packages;
- all sources, tests, scripts and DocC live inside this folder;
- DocC is source-owned under `Sources/AppLifecycle/Documentation.docc/`;
- verification must use a worktree-local scratch path outside this package folder;
- verification must not leave `.build`, `.swiftpm`, `Package.resolved` or archive artifacts inside this folder.

## Public API ownership

The package owns:

- `AppLifecyclePhase`;
- `AppLifecycleEventKind`;
- lifecycle event and snapshot models;
- lifecycle attribute privacy/redaction primitives;
- launch classification;
- lifecycle persisted state contracts;
- in-memory state store;
- lifecycle clock abstractions;
- default lifecycle manager.

## Privacy and security

The package must not expose:

- user identifiers;
- auth/session tokens;
- cookies;
- backend secrets;
- process environment dumps;
- raw file-system paths;
- raw app-specific navigation payloads.

String attribute descriptions are redacted by default. Sensitive-looking attribute keys must be sanitized before events are stored and published.

## Concurrency

All public value types must be `Sendable`.

The default manager is an actor. Lifecycle state changes and stream continuation storage are isolated behind that actor boundary.

## Multi-target policy

A future multi-target split is allowed only if every target remains inside this package folder and no sibling dependency is introduced.

## Integration policy

Examples of integrations that must not live in this root package:

- `AppLifecycle + AppAnalytics` lifecycle event tracking;
- `AppLifecycle + AppLogging` foreground/background log enrichment;
- `AppLifecycle + AppSession` session restoration policy;
- `AppLifecycle + AppBackgroundTasks` background refresh scheduling;
- `AppLifecycle + AppDiagnostics` provider registration.

Those belong in optional helper packages or host app composition code.
