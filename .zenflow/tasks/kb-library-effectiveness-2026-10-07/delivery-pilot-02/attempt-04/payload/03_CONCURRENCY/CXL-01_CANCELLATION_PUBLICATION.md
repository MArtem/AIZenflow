# CXL-01 — cancellation and latest-invocation publication

Status: candidate practical module, version 0.2. This is an independently authored
mechanism example, not an app patch, an installation, or proof of Library benefit.

## Select before deciding a change

After the authoritative KB concurrency rules and observed source/consumer facts, select this
module when an asynchronous invocation can be replaced or cancelled before it publishes state,
errors or callbacks. Read it before choosing the fix. Keep normative requirements in the KB;
this module supplies a concrete mechanism and falsification traces. Existing project mode,
permissions and exact payload pin still govern selection; this candidate does not activate itself.

Do not select it solely because `Task` appears. A synchronous nil-input branch with no outstanding
work, a proven single-operation intake, or an unrelated synchronous refactor is a negative control.
A clean existing identity/cancellation guard is a reason to leave code unchanged.

## Establish the contract first

Name the real state owner/actor, invocation entry, replacement and dismissal events, every producer
that may ignore cancellation, and every publication consumer. Decide what the current operation's
cancellation means: keep prior state, restore last value, publish idle, or publish cancelled. This
example explicitly chooses cancelled; do not impose that UX on an app.

Distinguish three promises: request cancellation, reject obsolete publication, stop or undo side
effects. None implies the other two. A generic Cancellable requires invoking its cancellation API;
discarding a handle alone is not that API contract. Inspect callers before claiming an actual UI race.

## Mechanism

1. On the owning actor, invalidate the previous invocation and request cancellation of its handle.
2. Assign identity to this invocation, independent of query text. A→B→A contains three invocations.
3. After each relevant suspension, validate current identity and cancellation before publishing
   success **and generic error**. An await allows reentrancy even on the same actor.
4. Clean up only resources belonging to that invocation. An old defer must not clear a new handle.
5. Explicit owner cancellation invalidates publication immediately and applies the agreed terminal
   state. A producer may still complete later; drain or bound its lifetime separately.

An existing stable handle identity, actor-owned token, or proven serialized intake can implement
these invariants. Do not prescribe a new generation counter, architecture or wrapper when the
existing ownership already proves them. Query equality is insufficient for repeated inputs.

Unsafe shape: `state = try await producer()` followed by an unconditional `catch { state = failed }`
permits both stale success and stale generic failure. Calling cancel on the old task does not repair
that publication contract when the producer ignores cancellation.

For a review-only task, stop here after this mechanism slice. Identify the actual promise violated:
a late publication capability is not automatically a proven current-screen defect or contract violation.
State caller reachability and contract uncertainty separately. Also record actual isolation,
retention and resource bounds: an unstructured task can retain its owner across await; cancellation
in deinit is insufficient. Rejecting stale publication does not bound cancellation-ignoring work.
The full example is for implementation or a specific mechanism question unresolved by source facts
and this slice. Routine ownership tracing does not require it; an example cannot replace missing
project facts. It is not a mandatory review read.

## Checked example

The UI presentation state is genuinely MainActor-owned. The Sendable work closure owns its producer;
expensive synchronous work must be kept off the UI actor by the producer's actual API. This example
has one stored current handle. Repeated replacement can leave multiple cancelled producers alive:
real integration needs cancellation-cooperative bounded work, explicit backpressure, or a concurrency
limit. The example is not a resource-limit implementation.

The task retains its owner until work completes. Do not rely on deinit for cancellation: the caller
must invoke cancel at the agreed lifetime event. It must not return or expose handles that callers
cancel independently unless the state contract covers that path. `startIfIdle` is an intake alternative;
use it only when rejecting overlap is the intended product behavior. The returned handle lets the
fixture await completion; cancellation authority remains with the owner. An app-facing adaptation
should keep this handle private unless independent handle cancellation is separately specified.

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

No suspension occurs between the final guard and state mutation on the owner actor. If actual
publication crosses another actor, queue, callback or await, revalidate at that consumer boundary.
The example maps current CancellationError to cancelled. It preserves current genuine errors;
obsolete errors are ignored rather than shown as current failures.

## Eight falsification traces

The local fixture uses continuations to control completion, not timing sleeps. Its producer
intentionally ignores cancellation. Every created request is completed and every task awaited.

| Trace | Required observation |
| --- | --- |
| A starts; B starts; B succeeds; A succeeds | B remains visible |
| A starts; B starts; B succeeds; A throws generic error | B remains visible |
| A starts; owner cancels; producer returns | Agreed cancelled state remains |
| A-first → B → A-second; first A completes last | Latest A remains, despite equal query values |
| Current operation fails genuinely | Failure remains observable |
| Intake rejects overlap | Rejected invocation never runs; no inferred replacement defect |
| Durable write commits; presentation is cancelled | Commit remains; no rollback claim |
| A finishes while B is pending | B handle survives A cleanup and can still be cancelled |

The durable-write trace uses a committed actor ledger model, not disk/database transaction evidence.
Do not claim write rollback, SDK callback safety or device behavior from these checks.

## Verification envelope and limits

Verify the exact example and eight controlled traces under the project's actual language mode,
compiler/SDK and permitted checks. Strict Swift 6 concurrency and warnings-as-errors are a useful
profile when compatible. Keep exact toolchain identity, source parity and observed results in the
task-owned evidence receipt; this reusable module is not a task-history index.

The controlled traces validate a mechanism model. App adoption, SDK callback behavior, real durable
storage, iPhone Simulator coverage, delivery or causal KB + Library improvement require their own
evidence and authority. iPad and physical-device checks follow the current user scope; omitted
checks never become PASS. Candidate payload admission is separate from existing project payloads.

Normative owners:
[concurrency standard](../../../baseline/docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md),
[engineering quality](../../../baseline/docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md).
Return to the [concurrency route](COPY_ONLY_CONCURRENCY_ROUTE.md) for broader concurrency risks.

## Integration acceptance and goal check

Accept an integration only with the real caller/producer/consumer trace, agreed cancellation state,
guards at all publication paths, invocation-owned cleanup, and a resource/lifetime bound. Preserve
current errors, public API and existing architecture unless the task explicitly changes them.
If replacement cannot occur under the contract, record that evidence instead of adding machinery.
If a check only exercises an equivalent duplicate of the patch, it does not validate the patch.

Keep this module only if addressable delivery improves task outcomes or decision cost without
false-positive fixes. Missing delivery, worse outcomes, or reading overhead without a useful decision
is contrary evidence; refine within the approved iteration limit or remove its routing. Passing these
eight traces is a prerequisite for the example, not the success criterion for the overall plan.
