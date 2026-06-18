# Iteration 19 Report — AppStateMachine

## Summary

Created `AppStateMachine`, a standalone app-independent Swift package for validated state machine definitions, guarded transitions, side-effect boundaries, snapshots, and in-memory actor-backed state storage.

## Included API areas

- `StateMachineID`
- `StateID`
- `StateEventID`
- `StateGuardID`
- `StateActionID`
- `StateMetadata`
- `StateTransition`
- `StateMachineDefinition`
- `StateMachineEvent`
- `StateMachineSnapshot`
- `StateTransitionEvaluation`
- `StateTransitionGuard`
- `StateTransitionAction`
- `StateMachineStore`
- `InMemoryStateMachineStore`
- `StateMachineClock`
- `SystemStateMachineClock`
- `ManualStateMachineClock`
- `AppStateMachine`

## Architecture decisions

### Persistence boundary

Durable persistence is intentionally not implemented inside the package. Host apps can provide persistence through `StateMachineStore`. This keeps the root package independent from files, databases, caches, and sibling SDK packages.

### Side-effect boundary

Guards and actions are explicit host-owned protocol implementations. The package does not silently perform analytics, logging, networking, notification, file, or database work.

### Redacted diagnostics

Descriptions redact state, event, action, guard, metadata, and machine identifiers. Metadata values are never included in descriptions.

### Strict concurrency

Mutable runtime state is isolated in actors:

- `AppStateMachine`
- `InMemoryStateMachineStore`
- `ManualStateMachineClock`

## Verification status

The package verifier runs:

```bash
swift test
swift test -Xswiftc -strict-concurrency=complete
```

using a worktree-local scratch path outside the package folder.

## Platform note

Verification was designed to run with Swift Package Manager. Apple platform deployment declarations are included in `Package.swift`, but no macOS/Xcode-only branch is claimed as separately verified unless that verification is performed on macOS/Xcode.
