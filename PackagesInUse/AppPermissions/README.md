# AppPermissions

`AppPermissions` is a standalone, app-independent Swift package for normalizing permission state and permission request flows across iOS-oriented apps.

It provides generic permission contracts, state models, readiness evaluation, deterministic test managers, and compile-gated system providers where Apple frameworks are available.

## Goals

- Keep permission logic app-independent.
- Normalize platform authorization states into a single `PermissionState` model.
- Provide deterministic managers for tests and previews.
- Avoid product-specific permission copy.
- Avoid dependencies on networking, analytics, logging, navigation, diagnostics, session, or app configuration packages.

## What belongs here

- Permission identifiers.
- Permission state normalization.
- Permission manager/provider protocols.
- Manual/static/composite managers.
- Info.plist usage-description key requirements.
- Platform providers behind `canImport` guards.

## What does not belong here

- Product-specific permission explanation text.
- App-specific screens or alerts.
- Analytics event emission.
- Navigation to concrete app screens.
- Logging or diagnostics integration.
- Feature-specific permission policies.

## Basic usage

```swift
let manager = ManualPermissionManager(
    supportedKinds: [.camera],
    defaultState: .notDetermined
)

let snapshot = await manager.snapshot(for: .camera)
let decision = PermissionReadinessEvaluator().decision(for: snapshot)
```

## System manager

```swift
let manager = SystemPermissionManagerFactory.makeDefault()
let cameraState = await manager.state(for: .camera)
```

Notification permission requests can inject the app-owned notification center so app delegates/tests keep lifecycle ownership:

```swift
let provider = UserNotificationPermissionProvider(
    notificationCenter: .current(),
    options: [.alert, .badge, .sound]
)
let outcome = try await provider.request(.notifications)
```

On platforms without native Apple permission frameworks, the factory returns an unavailable static manager.

## Testing

```swift
let manager = ManualPermissionManager(
    supportedKinds: [.camera],
    requestOutcomes: [
        .camera: PermissionRequestOutcome(kind: .camera, state: .denied, didPromptUser: true)
    ]
)
```

## Verification

```bash
./Scripts/verify_package.sh
```
