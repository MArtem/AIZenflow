# ``AppBackgroundTasks``

Build deterministic, product-independent background task scheduling and execution boundaries.

## Overview

`AppBackgroundTasks` contains portable primitives for registering, scheduling and executing background work without coupling the package to app-specific jobs, networking, sync engines, analytics, lifecycle policy or diagnostics exporters.

The root package intentionally does not submit native tasks directly. Native `BGTaskScheduler` submission is a host-app boundary because it depends on entitlements, Info.plist identifiers and app lifecycle setup.

## Topics

### Identifiers and requests

- ``BackgroundTaskIdentifier``
- ``BackgroundTaskKind``
- ``BackgroundTaskRequest``
- ``BackgroundTaskRegistration``

### Execution

- ``BackgroundTaskExecutionContext``
- ``BackgroundTaskHandling``
- ``AnyBackgroundTaskHandler``
- ``BackgroundTaskResult``
- ``DefaultBackgroundTaskManager``

### Scheduling

- ``BackgroundTaskScheduling``
- ``ManualBackgroundTaskScheduler``

### Diagnostics

- ``BackgroundTaskEvent``
- ``BackgroundTaskDiagnosticSnapshot``
