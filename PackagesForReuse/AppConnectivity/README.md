# AppConnectivity

`AppConnectivity` is a 100% single-folder standalone Swift package for app-independent connectivity monitoring.

It provides a normalized connectivity model that can be used by networking, sync, downloads, uploads, media, diagnostics, feature flags, and UI state without coupling those packages to each other.

## Goals

- Represent online/offline/unknown/requires-connection states.
- Represent interface kind: Wi-Fi, cellular, wired Ethernet, loopback, other, unknown.
- Represent expensive and constrained connections.
- Expose `AsyncStream`-based connectivity snapshots.
- Provide test-friendly manual/static monitors.
- Provide a native `Network.framework` monitor on Apple platforms when available.
- Keep native monitor lifecycle explicit: `start()` is idempotent while active, `stop()` is terminal, and a new monitor instance is required for a fresh native lifecycle.
- Avoid product-specific routing, analytics, logging, copy, or networking dependencies.

## Installation

Copy the whole `AppConnectivity` folder into a project or workspace and add it as a Swift Package.

```bash
cd AppConnectivity
swift test
```

## Basic usage

```swift
import AppConnectivity

let monitor = ConnectivityMonitorFactory.makeDefault()
await monitor.start() // Idempotent while active. After stop, create a new monitor instance.

let snapshot = await monitor.currentSnapshot()
if snapshot.isAllowed(by: .conservative) {
    // Start a large sync/download only when the connection is usable and not constrained/expensive.
}
```

## Observing changes

```swift
let stream = await monitor.snapshots()
for await snapshot in stream {
    print(snapshot.status)
}
```

## Transition events

```swift
let changes = await ConnectivityChangeStream(monitor: monitor).changes()
for await change in changes {
    if change.becameOnline {
        // Resume queued work.
    }
}
```

## Lifecycle and cancellation

`NetworkPathConnectivityMonitor` wraps `NWPathMonitor`, whose cancellation is terminal. `start()` is idempotent while active; after `stop()`, create a new monitor instance instead of trying to restart the same one. `ManualConnectivityMonitor` is intended for tests/previews and can be driven directly through `update(...)`.

`ConnectivityWaiter.waitUntilAllowed()` waits on the caller task; cancel the caller task to stop waiting.

## Tests and previews

```swift
let monitor = ManualConnectivityMonitor(initialSnapshot: .offline())
await monitor.update(.online(interfaces: [.wifi]))
```

## What belongs here

- Connectivity state models.
- Native path monitoring abstraction.
- Test doubles.
- Privacy-safe diagnostics snapshot.
- Cost/constrained policy helpers.

## What does not belong here

- HTTP client logic.
- Retry queue implementation.
- Feature-specific offline UI.
- Analytics events.
- Logging implementation.
- Sync/download/upload orchestration.
- App-specific strings or route names.

Those integrations should live in optional IntegrationHelpers or the host app composition layer.

## Verification

```bash
./Scripts/verify_package.sh
```

This runs structure checks, forbidden dependency checks, `swift test`, and strict concurrency verification.
