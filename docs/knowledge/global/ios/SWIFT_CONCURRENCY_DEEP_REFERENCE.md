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
When owner release is required during suspension, capture the dependency/value state needed for work
and reacquire/check the owner only when applying the result. Deliberate retention needs its own bounded
lifetime contract; weak capture alone is not that proof.

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

## Invocation Publication Practical Slice

Select this section only when replacement/cancellation can precede externally visible completion
and the actual source/consumer trace leaves the mechanism unresolved after the operating rules.
For review, read Contract And Mechanism and stop before the example; expand the example/traces
for implementation or a specific unresolved mechanism question. Unrelated synchronous work,
no outstanding work, a proven single-operation intake, and an existing correct guard are negative
controls. A possible late completion is not proof of a reachable UI defect.

### Contract And Mechanism

Name the owning actor, invocation entry, replacement/dismissal events, cancellation-ignoring
producers and all publication consumers. Agree whether cancellation keeps prior state, restores a
value, publishes idle or publishes cancelled. Do not infer product UX from this example.
Requesting cancellation, rejecting obsolete publication and stopping/undoing side effects are
three separate promises. Invoke a generic Cancellable's cancellation API; discarding its handle
is not equivalent.

On the owner actor, invalidate the previous invocation and request handle cancellation; give the
new invocation its own identity. A→B→A has three identities, even when query text is equal.
After relevant suspensions, validate identity and cancellation before success **and generic error**
publication. Old cleanup must release only its own resources; an old defer must not clear the
replacement handle. Explicit owner cancellation revokes publication immediately and applies the
agreed terminal state. Separately drain or bound producers that ignore cancellation.

Use an existing stable handle, actor-owned token or proven serialized intake when it already
satisfies this contract. Do not add a generation counter or architecture without need. An
unconditional success assignment followed by an unconditional failure catch can publish either
obsolete result. No suspension may separate the final guard from mutation on the owner actor;
if publication crosses another actor, queue, callback or await, revalidate at that consumer boundary.
Cancellation handlers may run while operation work continues; shared mutable state needs real
synchronization. Retry loops need a cancellation exit before sleeping or starting another attempt.

### Illustrative Owner Example

This is an explanatory model, **not compiled or executed by this migration**. Verify against the
actual compiler/language mode and permitted checks before app adoption. UI state is MainActor-owned;
the Sendable producer must keep expensive synchronous work off that actor through its actual API.
The task retains the owner across await: cancel at the agreed lifetime event, not only in deinit.
One stored current handle does not limit surviving cancelled producers; use cooperative bounded
work, backpressure or a concurrency limit in a real integration.

The example chooses cancelled UX and preserves current genuine failures. The returned handle is
for a fixture to await completion; app adaptations should keep it private unless independent handle
cancellation has an agreed state contract. startIfIdle is an alternative only when rejecting overlap
is intended. It does not prove every caller uses that intake.

```swift
import Foundation

enum ScreenState: Equatable { case idle, loading, loaded(String), failed, cancelled }

@MainActor
final class PublicationOwner {
    // Identity denotes one invocation, not its query text. No wrapping counter.
    private final class Operation {}
    private var current: Operation?
    private var task: Task<Void, Never>?
    private(set) var state: ScreenState = .idle
    var hasActiveOperation: Bool { current != nil && task != nil }

    @discardableResult
    func start(_ work: @escaping @Sendable () async throws -> String) -> Task<Void, Never> {
        task?.cancel()
        let operation = Operation()
        current = operation
        state = .loading
        let handle = Task { @MainActor in
            defer {
                // Old completion must never remove a replacement's task handle.
                if current === operation { current = nil; task = nil }
            }
            do {
                let value = try await work()
                guard current === operation, !Task.isCancelled else { return }
                state = .loaded(value)
            } catch is CancellationError {
                guard current === operation else { return }
                state = .cancelled
            } catch {
                guard current === operation, !Task.isCancelled else { return }
                state = .failed
            }
        }
        task = handle
        return handle
    }

    func cancel() {
        // Contract of this example: explicit cancellation publishes .cancelled.
        current = nil
        task?.cancel()
        task = nil
        state = .cancelled
    }

    func startIfIdle(_ work: @escaping @Sendable () async throws -> String) -> Task<Void, Never>? {
        guard current == nil else { return nil }
        return start(work)
    }
}
```

### Falsification Traces And Evidence Limits

With controlled completions rather than timing sleeps, complete each created request and await
its task. These are scenario descriptions, not executed tests or permission to create tests.

| Trace | Required observation |
| --- | --- |
| A starts; B starts; B succeeds; A succeeds | B remains visible |
| A starts; B starts; B succeeds; A throws generic error | B remains visible |
| A starts; owner cancels; producer returns | Agreed cancellation state remains |
| A-first → B → A-second; first A completes last | Latest A remains despite equal inputs |
| Current operation fails genuinely | Failure remains observable |
| Intake rejects overlap | Rejected invocation never runs; no replacement defect inferred |
| Durable write commits; presentation is cancelled | Commit remains; no rollback inferred |
| A finishes while B is pending | B handle survives old cleanup and remains cancellable |

A committed actor-ledger model does not prove disk/database rollback, SDK callback safety,
owner deallocation, app adoption or device behavior. Verify the real caller/producer/consumer trace,
publication paths, cancellation UX, invocation-owned cleanup and lifetime/resource bounds. An
identical duplicate model is not evidence for an app patch. Keep existing errors, public API and
architecture unless their change is explicitly authorized. Tests/build/runtime remain subject to
current permissions; unperformed checks remain UNVERIFIED. This slice does not establish a quality
or token benefit.

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
- [Task cancellation](https://docs.swift.org/latest/documentation/swift/task/cancel%28%29/)
- [Concurrency language model](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
- [Migrating to Swift 6](https://www.swift.org/migration/)
- [Swift migration strategy](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/migrationstrategy/)
- [The Swift Programming Language](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/)
- [Swift Evolution](https://www.swift.org/swift-evolution/)
