# 04 — Swift Concurrency

## Core model

Concurrency correctness is based on isolation and ownership, not on the assumption that `async` means “background.” Swift 6 provides compile-time data-race safety; Swift 6.2+ also introduced more approachable isolation behavior and explicit `@concurrent` opt-in for work that should run on the concurrent executor.

The project profile MUST record language mode and relevant isolation/upcoming-feature settings because async execution semantics can differ by toolchain/settings.

## Actor isolation

MUST:

- identify the isolation domain of mutable shared state;
- keep UI-owned mutable state on `MainActor` unless there is a concrete reason otherwise;
- treat every `await` in actor-isolated code as a possible reentrancy boundary;
- revalidate assumptions after suspension when other actor jobs could have changed state.

Do not equate actor with thread. Ordinary actors serialize isolated access but normally use shared runtime execution resources.

## Sendable

- Values crossing isolation boundaries must satisfy the compiler’s sendability rules.
- Do not add `@unchecked Sendable` to silence diagnostics.
- `@unchecked Sendable` requires a documented synchronization invariant, proof that all mutable state is protected, and focused tests/review.
- `@preconcurrency import` is temporary compatibility debt, not a normal fix; document why the imported module cannot yet satisfy current checking.

## Task creation

Before any unstructured `Task {}`/`Task.detached`, answer:

1. Who owns the work?
2. When should it stop?
3. What actor/isolation does it inherit/use?
4. What state may it mutate?
5. How is cancellation observed?
6. Can the task outlive the object/view that initiated it?

Prefer structured forms (`async let`, task groups, async child APIs, SwiftUI `.task`) when child work naturally belongs to a parent operation.

## Task.detached

`Task.detached` is a review trigger. Use only when deliberately escaping inherited actor/task context is necessary and sendability/lifetime are proven. It must not be a generic “run this in background” button.

For modern Swift, prefer a correctly isolated async API or explicit `@concurrent` where appropriate to the configured toolchain.

## Cancellation

Cancellation is cooperative.

MUST:

- propagate cancellation through structured async APIs;
- avoid swallowing `CancellationError` as an ordinary failure;
- check cancellation in long CPU loops/custom operations that do not naturally suspend through cancellation-aware APIs;
- cancel superseded work (search, refresh, repeated loads) when stale results would be harmful;
- prevent stale tasks from overwriting newer state.

## SwiftUI task lifetime

For work whose lifetime is the view, SHOULD prefer `.task` / `.task(id:)` so SwiftUI can cancel the structured task when identity/lifetime changes.

Avoid `.onAppear { Task { ... } }` unless the independently owned task is intentional.

## Retention

A Task closure may strongly capture `self`. If `self` also stores the task, a retain cycle can occur:

```text
self -> Task -> closure -> self
```

Long-running tasks must be reviewed for lifecycle/retention. `[weak self]` alone is not magic: binding `guard let self` before a long `await` can strongly retain the object for that async call.

## Locks / GCD / semaphores

- Prefer actors/structured concurrency for new Swift-native shared state when appropriate.
- Raw locks are allowed when performance/interoperability requires them but need a clear invariant.
- Blocking waits (`DispatchSemaphore.wait`, `DispatchGroup.wait`) are review triggers because they can deadlock, block cooperative threads, or create priority inversion.
- Do not call blocking synchronization from actor/main-thread paths without strong justification.

## MainActor and responsiveness

MUST keep substantial parsing, image processing, compression, crypto, large mapping/sorting, or other CPU-heavy work off `MainActor` unless measured to be trivial.

A network `await` itself does not block the main thread, but synchronous work before/after the suspension can.

## Concurrency gate requires

For R3+ concurrency changes:

- build under project’s strict concurrency configuration;
- targeted tests for cancellation/race-sensitive behavior;
- Thread Sanitizer in Simulator when meaningful and feasible;
- review of `Task`, `Task.detached`, `@unchecked Sendable`, `nonisolated(unsafe)`, locks and continuations;
- explicit note of actor/lifetime/cancellation design.
