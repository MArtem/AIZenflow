# AppStateMachine Reuse Notes

## Purpose

`AppStateMachine` is a standalone reusable package for app-independent state-machine primitives: safe identifiers, transition definitions, guarded transitions, action boundaries, snapshots, explicit store boundary, deterministic clocks, and actor-backed in-memory storage.

## SwiftPM Usage

Copy this folder into a project's package area and add it as a local package or dependency. The package has no sibling package dependencies and no remote dependencies.

Run package verification before adoption:

```zsh
cd ./PackagesForReuse/AppStateMachine
./Scripts/verify_package.sh
```

## Source-Only Usage

For source-only integration, copy this package to the target project's active package/source area and add only `Sources/AppStateMachine/**/*.swift` to the relevant target. Keep `README.md`, `PackageContract.md`, DocC, tests, and `Scripts/verify_package.sh` with the package folder so it remains portable.

## Host Ownership

The package owns state-machine mechanics only. Host apps own concrete state/event taxonomies, UX copy, analytics, logging, persistence backend, side-effect idempotency, retry/compensation policy, and product-specific transition semantics.

`StateMachineStore` is throwing by design so durable persistence failures remain visible to host policy. `AppStateMachine` serializes transition execution across awaiting guards/actions to avoid actor-reentrancy races. Transition actions execute before snapshot persistence, so host actions should be idempotent or compensatable when durable saves can fail after an action succeeds.

## Current TchopApp Decision

Vault-only. Current `TchopApp` already has product-specific app/session/navigation/lifecycle state owners. There is no direct generic state-machine runtime to migrate now; adopting this package would require a product/architecture decision and should not be done mechanically.
