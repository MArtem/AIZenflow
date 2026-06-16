# AppStateMachine

`AppStateMachine` is a standalone Swift package for app-independent state machine primitives.

It provides validated identifiers, transition definitions, guarded transitions, action boundaries, snapshot storage contracts, an in-memory actor store, deterministic clocks for tests, and privacy-safe descriptions.

## Design goals

- Keep every root package single-folder standalone.
- Keep state machine logic independent from any product domain.
- Avoid sibling SDK imports and remote dependencies.
- Keep persistence and side effects behind explicit host-owned protocol boundaries.
- Avoid exposing full state, event, guard, action, metadata, or machine identifiers in diagnostic descriptions.

## Basic usage

Create states, events, and transitions:

```swift
let draft = try StateID("draft")
let published = try StateID("published")
let publish = try StateEventID("publish")

let definition = try StateMachineDefinition(
    id: try StateMachineID("article"),
    states: [draft, published],
    initialState: draft,
    transitions: [
        StateTransition(from: draft, event: publish, to: published)
    ]
)

let machine = AppStateMachine(definition: definition)
let result = try await machine.send(StateMachineEvent(id: publish))
```

## Persistence boundary

The package includes `InMemoryStateMachineStore` for tests and lightweight runtime use. Durable persistence belongs to the host app through `StateMachineStore`.

`StateMachineStore` operations throw so storage failures stay visible to host policy.

## Transition serialization

`AppStateMachine` serializes transition execution across awaiting guards and actions. This avoids reentrant actor interleaving where concurrent events could otherwise evaluate from the same snapshot.

## Side-effect boundary

Transition guards and actions are host-owned implementations of `StateTransitionGuard` and `StateTransitionAction`. The package does not hide file, database, network, analytics, or notification work inside the root mechanism.

Actions execute before the next snapshot is persisted. Host actions should be idempotent or compensatable when durable storage can fail after a side effect succeeds.

## Diagnostics

Public `description` and `debugDescription` implementations redact identifiers and metadata values by default.
