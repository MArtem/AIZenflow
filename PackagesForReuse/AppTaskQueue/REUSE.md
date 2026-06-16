# AppTaskQueue Reuse Notes

## Purpose

`AppTaskQueue` is a standalone reusable package for local task queue primitives: task identity, payload validation, priority, deferred scheduling, retry policy, explicit store boundary, and one-task-at-a-time runner execution.

## SwiftPM Usage

Copy this folder into a project's package area and add it as a local package or dependency. The package has no sibling package dependencies and no remote dependencies.

Run package verification before adoption:

```zsh
cd ./PackagesForReuse/AppTaskQueue
./Scripts/verify_package.sh
```

## Source-Only Usage

For source-only integration, copy this package to the target project's active package/source area and add only `Sources/AppTaskQueue/**/*.swift` to the relevant target. Keep `README.md`, `PackageContract.md`, DocC, tests, and `Scripts/verify_package.sh` with the package folder so it remains portable.

## Host Ownership

The package owns queue mechanics only. Host apps own durable persistence, crash recovery, background scheduling, telemetry, user-visible errors, task-type taxonomy, network/file execution, and multi-process reservation policy.

`AppTaskQueueStore` implementations must serialize reservation/update operations for their backend if multiple runners or processes can observe the same queue. Reserved-task expiry and recovery are product-specific and belong in the host store or integration layer.

## Current TchopApp Decision

Vault-only. Current `TchopApp` has no generic product task queue runtime to migrate. `./PackagesInUse/AppNetworking` already owns API-specific offline queue behavior, and connecting `AppTaskQueue` now would duplicate mechanisms without a current app flow.
