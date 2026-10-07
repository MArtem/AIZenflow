# Swift Concurrency Deep Reference

## Load When
Use for async/await design, actor ownership, task trees, cancellation, callback bridging, streams, shared mutable state, Swift language-mode migration, or concurrency diagnostics.

The operating rules and section-selection contract remain in `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`.
Maintenance belongs to the reusable knowledge boundary; review these sections when ownership, language-mode or routed consumer contracts change.

## Core Model
Concurrency is about overlapping progress; parallelism is simultaneous execution. `async` does not promise a background thread. An actor provides data isolation, not a dedicated thread. `@MainActor` expresses executor ownership of UI-facing state; it is not a general-purpose queue wrapper.

Structured concurrency ties child-task lifetime, cancellation, priority, and result collection to a lexical parent. Unstructured `Task` is appropriate only when a lifecycle owner stores or otherwise bounds it. Detached tasks discard actor context and task-local structure and require a specific reason. Do not use them to evade isolation or extend work beyond its owning operation without intent. Check priority inheritance and executor choices against the actual bottleneck; they do not replace correct ownership.

## Isolation Design
- Start from the mutable state and assign one isolation owner.
- Prefer immutable `Sendable` values across boundaries.
- Keep actor methods cohesive so callers do not need multi-call read/modify/write sequences.
- Do not expose mutable actor state through reference types that can escape isolation.
- Use `nonisolated` only for behavior independent of isolated state.
- Treat global mutable state and singleton caches as concurrency design, even when access is currently main-thread-only.

## Task Ownership
Every long-lived task needs:

- creator and runtime owner;
- start trigger and duplicate-start policy;
- cancellation trigger;
- result application rule;
- stale-result protection;
- error and observability path;
- release behavior.

View appearance is not a durable owner for work that must survive navigation. Conversely, application singletons must not own screen-specific work indefinitely.

Trace retention across suspension: weak capture followed by a strong local before `await` can retain
the owner. Cancellation only in `deinit` cannot release a task that itself retains that owner; identify
the actual replacement/dismissal trigger and completion/error propagation. Inspect affected callers,
lifecycle and consumers, not just the edited async function.

## Cancellation
Cancellation is cooperative. Check it before expensive work, at suspension boundaries where latency matters, and before applying results. Propagate `CancellationError` without turning it into user-visible failure unless the product explicitly treats cancellation as failure.

Use cleanup handlers or narrow cancellation shielding only to finish or roll back an already-started integrity operation. A shield must not become a way to ignore user cancellation for unbounded work.

A producer can ignore cancellation and later return success or throw a generic error. Check publication
authority on both paths against the actual consumer contract; recognizing only `CancellationError`
does not suppress every obsolete completion. Cancellation does not undo an already committed side effect.
Do not invent a defect solely because an identity mechanism is absent: existing serialized ownership may
already satisfy the required contract.

## Continuations And Callbacks
- Use checked continuations by default.
- Resume exactly once on every callback path, including a callback invoked synchronously during registration.
- Define cancellation behavior before bridging; a continuation alone does not cancel the underlying operation.
- Preserve callback isolation/thread semantics explicitly.
- Keep the callback registration alive for the required lifetime and unregister it on cancellation or deinit.

## Streams
For `AsyncSequence` and continuation-backed streams, define buffering, overflow, termination, cancellation, producer ownership, and error semantics. An unbounded stream is an unbounded memory policy. Name fan-out concurrency limits, backpressure and producer/consumer termination ownership. Multiple consumers may require multicast semantics rather than repeated subscriptions.

## Reactive And Queue Bridges
Preserve subscription/disposal lifetime, scheduler versus actor ownership, demand/buffering and error/completion/cancellation semantics in both directions. Avoid duplicate state or silently lost events; a value conversion alone does not establish lifetime or ordering parity. Legacy queue bridges need one explicit synchronization model; layering queues and actors is not proof of safety. Framework adoption/replacement requires its own approved benefit and scope.

## Ordering And Stale Results
At each suspension, check stale state, reentrancy and the assumptions that serialize publication. Awaiting does not guarantee that an older request finishes first. Use task replacement, request identifiers, monotonic generations, actor serialization, or domain-specific idempotency. The chosen strategy must match whether operations may be cancelled, merged, retried, or committed durably.

## Swift 6.x Discipline
- Record compiler version, language mode, strict-concurrency settings, default actor isolation, and enabled upcoming features separately.
- Resolve warnings by expressing actual ownership; do not use or retain `@unchecked Sendable`,
  `nonisolated(unsafe)`, `@preconcurrency`, warning suppressions, or broad/fake `@MainActor`
  annotations as workarounds.
- Migrate incrementally by module when a direct switch creates excessive ambiguity.
- Re-check third-party modules and generated code under the intended language mode.
- Revisit guidance after Swift releases because default isolation and diagnostics can change materially.

## Testing And Evidence
Select checks proportionate to the changed invariants and current user permission. The following are
evidence choices, not authority to write tests or run builds/runtime. Missing evidence stays UNVERIFIED.
- Type-check/build every affected target under intended settings.
- Use deterministic fakes for clocks, sleeps, streams, and network completion.
- Test cancellation, duplicate starts, stale completion, owner deallocation, and error propagation.
- Use Thread Sanitizer where compatible, but do not treat a clean run as proof of race freedom.
- Profile actor contention, main-actor occupancy, task growth, and cancellation latency when performance matters.

## Primary Sources
- [Migrating to Swift 6](https://www.swift.org/migration/)
- [Swift migration strategy](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/migrationstrategy/)
- [The Swift Programming Language](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/)
- [Swift Evolution](https://www.swift.org/swift-evolution/)
