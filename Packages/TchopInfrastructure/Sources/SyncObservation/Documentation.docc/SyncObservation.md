# ``SyncObservation``

Observable UI-facing sync status storage built on top of the framework-neutral `SyncCore` reporting contract.

## Ownership

Use `SyncStatusStore` when a UI or diagnostics surface needs to observe sync progress and counters. Sync engines that do
not expose status should depend only on `SyncCore` and use its default no-op reporter.
