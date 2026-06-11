# ``AppConnectivity``

A standalone infrastructure package for privacy-safe connectivity monitoring.

## Overview

`AppConnectivity` provides a normalized model over platform network reachability/path state. It intentionally does not know about requests, APIs, sync jobs, analytics, or UI copy.

Use it when app code needs to answer questions such as:

- Is the app currently online?
- Is the connection expensive?
- Is the connection constrained by Low Data Mode?
- Did connectivity just become available?
- Should this operation be postponed under the selected cost policy?

## Core types

- ``ConnectivityStatus``
- ``ConnectivityInterfaceKind``
- ``ConnectivityCostPolicy``
- ``ConnectivitySnapshot``
- ``ConnectivityChange``
- ``ConnectivityMonitoring``
- ``ManualConnectivityMonitor``
- ``StaticConnectivityMonitor``
- ``ConnectivityWaiter``

## Lifecycle

`NetworkPathConnectivityMonitor` is actor-isolated and wraps `NWPathMonitor`. `start()` is idempotent while active. `stop()` is terminal; create a new monitor instance for another native monitoring lifecycle. `ConnectivityWaiter` is caller-task-owned, so cancelling the caller task stops the wait.

## Standalone rule

This package must stay single-folder standalone. Cross-package behavior belongs in optional IntegrationHelpers or host app composition.
