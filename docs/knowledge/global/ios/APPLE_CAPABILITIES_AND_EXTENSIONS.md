# Apple Capabilities And Extensions

## Load When
Use when a feature touches entitlements, system services, app extensions, widgets, Live Activities, App Intents, Siri, notifications, background execution, associated domains, app groups, Spotlight, SharePlay, or another Apple capability.

## Capability Intake
For every capability, establish:

1. Product behavior and non-goals.
2. Supported iPhone/iPad OS versions and fallback.
3. Required framework, target, entitlement, provisioning, account, identifier, associated domain, or server component.
4. App/extension/shared-container ownership.
5. Privacy permission and data use.
6. Background, lifecycle, quota, and system-scheduling semantics.
7. Simulator, physical-device, multi-device, and external-service evidence.
8. App Review and distribution implications.

An API compiling does not prove the capability is provisioned or operational.

## Target And Extension Boundary
- Keep extension memory, launch time, API availability, and background limits explicit.
- Share only the minimum data through App Groups or supported frameworks.
- Use stable, versioned shared data and coordinate concurrent access.
- Extensions must tolerate the containing app not running and stale/missing shared data.
- Do not import the whole app module into an extension to avoid defining a boundary.

## Notifications
Separate authorization, device token registration, provider registration, delivery, presentation, user response, and background handling. Tokens can change. Payloads are untrusted and size-limited. Silent notifications are opportunistic and must not be the sole correctness mechanism.

Test foreground/background/terminated state, disabled authorization, changed token, malformed/deep-link payload, notification service/content extensions, and provider environment.

## Background Execution
Select from background URLSession, BGTaskScheduler, audio/location modes, processing assertions, push hints, or foreground completion based on the actual work. The system controls scheduling and may terminate the process. Persist intent/checkpoints before suspension and make handlers idempotent, cancellable, time-bounded, and expiration-aware.

## Widgets
Widgets render snapshots/timelines under tight budgets and are not miniature apps. Keep data access bounded, placeholder/snapshot/timeline paths distinct, deep links stable, privacy redaction intentional, and App Group data versioned. Reload requests are hints and should be budgeted.

## Live Activities
Define authorization, Activity attributes/content state, start/update/end ownership, stale date, relevance, remote update security, token lifecycle, dismissal, and app relaunch reconciliation. Keep content compact and privacy-aware. Physical-device and lock-screen/Dynamic Island evidence is required for claims about real presentation.

## App Intents, Shortcuts, Siri, And Spotlight
- Model stable entities and identifiers independent of current UI objects.
- Keep parameters, disambiguation, errors, confirmation, authentication, and background availability explicit.
- Intent execution must call owned domain behavior rather than duplicate business rules.
- Index only useful, privacy-appropriate content and remove stale searchable items.
- Validate with AppIntentsTesting where supported, Shortcuts UI, and physical-device Siri voice for voice claims.

## Associated Domains And Deep Links
Treat universal links as a server-and-app contract. Verify association file content, hosting, caching, app entitlement, route parsing, authentication gating, and fallback. Custom URL schemes are globally claimable and must not carry secrets. Every external route is untrusted input.

## App Groups
App Groups expand the trust and corruption surface across targets. Inventory members, data formats, file protection, migration, coordination, cleanup, and account separation. Keychain access groups and App Groups are different mechanisms.

## Share, Action, Document, And File Provider Extensions
- Validate incoming items and security-scoped resources.
- Copy or coordinate files before source access expires.
- Bound memory and asynchronous work, complete/cancel the extension request exactly once.
- Document providers and File Provider domains require conflict, version, offline, and coordination semantics beyond ordinary import.

## StoreKit And Commerce
Use the dedicated StoreKit standard. Capability review must also include product configuration, signed transactions, entitlement restoration, pending/revoked/refunded states, family/group behavior where applicable, server dependency, and App Review rules.

## Capability Evidence Classes
- Static: target membership, entitlements, plist, associated domains, privacy manifest, provisioning configuration.
- Simulator: pure intent/entity logic, deep-link routing, widget previews/timelines, fixture-driven extension logic where supported.
- Physical device: push token/delivery, Siri voice, biometrics, lock-screen/Live Activity, camera/microphone, protected-data state, realistic background scheduling.
- Multi-device/service: CloudKit sharing, SharePlay, passkeys, continuity, provider/server callbacks.
- Distribution: archive, signing, TestFlight/App Store environment, production service configuration.

## Primary Sources
- [Apple technology overviews](https://developer.apple.com/documentation/technologyoverviews)
- [App extensions](https://developer.apple.com/app-extensions/)
- [App Intents](https://developer.apple.com/documentation/appintents)
- [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [ActivityKit](https://developer.apple.com/documentation/activitykit)

Review after WWDC/platform releases or any capability, entitlement, extension target, or service-contract change.
