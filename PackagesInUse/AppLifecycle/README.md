# AppLifecycle

`AppLifecycle` is a product-independent Swift package for modeling application lifecycle state, launch classification, lifecycle events and privacy-safe lifecycle diagnostics.

It is a mechanism package. It does not own product screens, routes, analytics events, logging backends, session restoration, push registration, background task scheduling or app-specific launch policy.

## What belongs here

- lifecycle phases;
- lifecycle events;
- launch classification;
- foreground/background counters;
- app lifecycle snapshots;
- privacy-safe lifecycle attributes;
- lifecycle diagnostics;
- in-memory lifecycle state store;
- manual/default lifecycle manager for host app composition.

## What does not belong here

- app-specific onboarding logic;
- auth/session restoration;
- analytics/logging/crash-reporting adapters;
- push token registration;
- background task scheduling;
- concrete SwiftUI scene wiring;
- product-specific route handling.

Cross-package or app-specific composition belongs in optional integration helpers or in the host app.

## Basic usage

```swift
let manager = DefaultAppLifecycleManager(initialPhase: .inactive)

try await manager.startLaunch(
    buildIdentity: AppLifecycleBuildIdentity(version: "1.0", build: "100")
)

try await manager.record(.didBecomeActive)
let snapshot = await manager.snapshot()
```

## Observing lifecycle events

```swift
let stream = await manager.eventStream()

Task {
    for await event in stream {
        // Forward to app-level logging, analytics or diagnostics if desired.
    }
}
```

## Privacy

Lifecycle attributes are privacy-aware. String descriptions are intentionally redacted and sensitive-looking keys are sanitized before storage in lifecycle events.

## Verification

Run from the package folder:

```bash
./Scripts/verify_package.sh
```

The script uses a worktree-local scratch path outside the package folder and must not leave `.build`, `.swiftpm` or `Package.resolved` inside the package.
