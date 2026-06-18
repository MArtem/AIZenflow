# ``AppLifecycle``

Model application lifecycle state without coupling the root package to product screens, routes, analytics, logging or session logic.

## Overview

`AppLifecycle` gives host applications a small set of lifecycle primitives:

- phases;
- events;
- launch classification;
- snapshots;
- diagnostics;
- event streams;
- privacy-aware event attributes.

The package is intentionally mechanism-only. Native app/scene callbacks should be observed by the host app and forwarded to `DefaultAppLifecycleManager` or another implementation of `AppLifecycleManaging`.

## Topics

### State

- ``AppLifecyclePhase``
- ``AppLifecycleEventKind``
- ``AppLifecycleEvent``
- ``AppLifecycleSnapshot``
- ``AppLifecycleDiagnostics``

### Launch classification

- ``AppLifecycleBuildIdentity``
- ``AppLaunchClassification``

### Storage

- ``AppLifecyclePersistedState``
- ``AppLifecycleStateStoring``
- ``InMemoryAppLifecycleStateStore``

### Management

- ``AppLifecycleManaging``
- ``DefaultAppLifecycleManager``

### Privacy

- ``AppLifecycleAttribute``
- ``AppLifecycleAttributeValue``
- ``AppLifecycleAttributePrivacy``
- ``AppLifecycleRedactor``
