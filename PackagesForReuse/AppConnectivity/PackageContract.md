# AppConnectivity Package Contract

## Package identity

- Name: `AppConnectivity`
- Type: root infrastructure package
- Portability: 100% single-folder standalone
- Required sibling packages: none
- External Swift Package dependencies: none

## Public responsibility

`AppConnectivity` owns the generic connectivity monitoring mechanism for iOS/macOS/tvOS/watchOS/visionOS-compatible apps.

It may expose:

- connectivity status models;
- interface kind models;
- expensive/constrained connection flags;
- connectivity snapshots and transitions;
- async snapshot observation;
- manual/static test monitors;
- native path monitor behind availability/import guards;
- explicit monitor lifecycle semantics for native monitors;
- privacy-safe diagnostics snapshots.

## Explicit non-goals

This package must not own:

- networking request execution;
- retry/offline queue orchestration;
- download/upload managers;
- app-specific offline UI;
- analytics/logging adapters;
- product-specific feature names;
- app-specific copy or localization keys.

## Dependency rules

The package must not contain:

```swift
.package(path: "../...")
```

The package must not import sibling modules such as:

```swift
import AppNetworking
import AppAnalytics
import AppErrors
import AppSession
import AppLogging
import AppObservability
import AppDiagnostics
```

## Privacy rules

Connectivity diagnostics must remain privacy-safe by default.

Allowed diagnostic fields:

- normalized status;
- normalized interface kinds;
- `isExpensive`;
- `isConstrained`.

Forbidden diagnostic fields:

- URLs;
- request headers;
- tokens;
- IP addresses;
- SSIDs;
- carrier names;
- user identifiers.

## Lifecycle rules

- Native `NetworkPathConnectivityMonitor.start()` must be idempotent while active.
- Native `NetworkPathConnectivityMonitor.stop()` is terminal because the underlying `NWPathMonitor` is cancelled. Hosts must create a new monitor instance for a fresh native lifecycle.
- Wait helpers must use caller-owned task cancellation; the package must not hide an unbounded detached task behind `waitUntilAllowed()`.

## Concurrency rules

- Public models must be `Sendable` where practical.
- Async observation should use `AsyncStream`.
- Test doubles should be actor-safe.
- No `unsafeFlags` in `Package.swift`.
- Strict concurrency is verified by script, not forced through public package manifest flags.

## Integration rules

If another package wants to use connectivity state, the integration must live outside this package.

Examples:

- `AppConnectivityNetworkingIntegration`
- `AppConnectivitySyncIntegration`
- `AppConnectivityDiagnosticsIntegration`
- `AppConnectivityDownloadsIntegration`

Root package remains mechanism-only.


## Iteration Standards Hardening

This package follows the hardened single-folder standalone rules:

- DocC is source-owned: `Sources/AppConnectivity/Documentation.docc/`.
- Verification uses an external SwiftPM scratch path and must not create `.build` or `.swiftpm` inside the package folder.
- The package has no sibling path dependencies and no imports of sibling SDK modules.
- Multi-target package layouts are allowed only when every target, test, fixture, script, and documentation file remains inside this package folder.
- Swift source and package metadata must not contain unresolved template placeholders.
- Package tests must cover native monitor start/stop idempotency when Apple `Network.framework` is available.
