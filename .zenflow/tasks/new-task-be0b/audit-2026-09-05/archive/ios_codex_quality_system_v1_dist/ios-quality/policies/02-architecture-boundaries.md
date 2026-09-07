# 02 — Architecture and Boundaries

## Goal

Maintain understandable dependency direction and avoid accidental coupling while remaining compatible with the project’s chosen architecture.

## MUST

- Respect the existing dependency graph unless the task explicitly changes it.
- Keep UI framework types out of domain/pure logic modules unless that module is intentionally UI-specific.
- Keep persistence DTO/storage details from leaking into unrelated UI/domain APIs when a stable boundary already exists.
- Do not create bidirectional module dependencies.
- Side-effecting infrastructure (network, disk, keychain, clock, randomness, analytics) MUST have a testable seam when behavior depends on it.
- Avoid hidden global mutable state.
- New shared mutable services MUST define synchronization/isolation strategy.

## Ownership model

For each mutable model/service, identify:

```text
Creator -> Owner -> Consumers -> Lifetime -> Mutation API -> Isolation
```

If those cannot be described, the design is not ready.

## Dependency injection

SHOULD inject dependencies where it improves testability or lifetime control. Avoid DI ceremony for pure stateless helpers.

Prefer:

```swift
protocol FeedRepository: Sendable {
    func load() async throws -> [Article]
}
```

when consumers need an abstraction and multiple implementations/tests are real.

Avoid creating a protocol solely because “everything must have an interface.”

## State machines

When several booleans/optionals represent mutually exclusive states, SHOULD model the state explicitly:

```swift
enum LoadState<T> {
    case idle
    case loading
    case loaded(T)
    case failed(ErrorViewState)
}
```

This reduces invalid combinations and makes transitions reviewable.

## Cross-layer errors

Infrastructure-specific errors SHOULD be translated at boundaries when exposing them would couple higher layers to implementation detail. Preserve useful diagnostics in logs/underlying errors.

## Architecture change gate

A broad architecture change is R4/R5 when it:

- moves ownership across modules;
- changes public contracts used broadly;
- changes persistence/network/auth boundaries;
- requires wide call-site churn;
- makes rollback difficult.

Such work requires an ADR/change plan and explicit human approval.
