# AppStateMachine

`AppStateMachine` is a standalone Swift package for app-independent state machine primitives across iOS, macOS, watchOS, and tvOS.

## What it provides

- validated state machine, state, event, guard, and action identifiers;
- transition table validation;
- guarded transitions;
- action execution boundary;
- immutable snapshots with revisions;
- store protocol for host-owned persistence;
- in-memory actor store;
- deterministic manual clock for tests;
- privacy-safe descriptions and debug descriptions;
- source-owned DocC documentation;
- fail-fast package verifier.

## What it deliberately does not provide

- no app-specific state names;
- no dependency on logging, diagnostics, persistence, queue, download, or upload packages;
- no built-in database or file persistence;
- no hidden network, file, notification, analytics, or telemetry side effects;
- no raw identifier or metadata leakage in diagnostic descriptions.

## Minimal example

```swift
import AppStateMachine

let idle = try StateID("idle")
let loading = try StateID("loading")
let start = try StateEventID("start")

let definition = try StateMachineDefinition(
    id: try StateMachineID("loader"),
    states: [idle, loading],
    initialState: idle,
    transitions: [
        StateTransition(from: idle, event: start, to: loading)
    ]
)

let machine = AppStateMachine(definition: definition)
let result = try await machine.send(StateMachineEvent(id: start))
```

## Runtime guarantees

`AppStateMachine` serializes `send(_:)` and `resetToInitialState()` operations across awaiting guards/actions. This is required because Swift actors are reentrant at suspension points; without an explicit transition lock, two concurrent events could evaluate from the same snapshot.

`StateMachineStore` operations are throwing by design. Durable stores must propagate file, database, or distributed-storage failures to the host instead of hiding them as rejected transitions.

Transition actions execute before the package commits the next snapshot. If an action succeeds but a durable store save later fails, the failure is thrown to the host so product code can decide how to reconcile the side effect and persistence state.

## Verification

Run from the package folder:

```bash
./Scripts/verify_package.sh
```

The verifier uses a worktree-local scratch path outside the package folder:

```text
../WorktreeScratch/AppStateMachine
```
