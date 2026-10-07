# Swift concurrency — curated copy-only route

Use after project-local rules for a change involving tasks, actors, isolation, cancellation or
asynchronous APIs. This route curates `IOS-03-01` through `IOS-03-14`; the imported files are not
independently approved for the active payload. Establish the actual Swift language mode, compiler
settings, deployment range and existing owner of mutable state before recommending a change.

For replacement/cancellation publication work, after the authoritative KB rules and observed source
facts, select [CXL-01](CXL-01_CANCELLATION_PUBLICATION.md#select-before-deciding-a-change) before
choosing the engineering fix or final review verdict. For review-only work, read from "Select before
deciding a change" through "Mechanism" and stop before "Checked example". Expand the example and
traces only for implementation, an unresolved specific mechanism question, or permitted verification.
Routine ownership tracing does not require the example; it cannot replace missing project facts.
Carry the slice's
contract, isolation, lifetime and resource limits into the review; do not infer a defect from a missing
mechanism when the actual consumer contract does not require it.
It is a candidate applied mechanism, not a new norm or a permission grant. Do not select it for
unrelated synchronous work or a proven clean serialized path. Existing approved payload pins do
not automatically acquire this module.

- Trace who creates, retains, cancels and awaits each task. Prefer structured child work; an unstructured
  task needs a documented lifetime and cancellation owner. Do not use `Task.detached` to evade
  actor isolation or propagate work past its owning screen/operation without intent.
  Check retention across suspension: weak capture followed by a strong local before `await`
  can keep the owner alive. Cancellation only in `deinit` is insufficient if a task retains it;
  trace the actual replacement/dismissal event and child completion/error propagation.
- Make actor ownership and cross-actor data transfer explicit. Check mutable reference types and
  `Sendable` across every boundary. Apply the first layer's prohibitions: do not propose
  `@unchecked Sendable`, `nonisolated(unsafe)`, `@preconcurrency`, warning suppressions or blanket/
  fake `@MainActor` as remedies. Use real actor/global-actor ownership, immutable `Sendable`
  values or a correctly isolated API. Existing prohibited occurrences remain blocking migration
  findings under the active baseline; this library cannot grant an exception by accepting a rationale.
- Check each suspension point for stale state, reentrancy and ordering assumptions. Keep UI
  mutations on the appropriate actor without placing expensive work on the main actor.
- Cancellation is cooperative, not proof that work stopped. Check meaningful cancellation points
  and operation identity before publishing both success and generic failure after replacement.
  Cancellation does not undo an already committed side effect. For continuations, prove exactly-once
  resume across success, failure and cancellation, including synchronously invoked callbacks.
- For async streams and fan-out, name buffer/concurrency limits, backpressure and producer/consumer
  termination ownership. Check priority inheritance and executor choices against the actual bottleneck,
  not as substitutes for correct ownership. Legacy queue bridges need one explicit synchronization
  model; layering queues and actors does not itself establish safety.
- For reactive/async bridges, inspect subscription/disposal lifetime, scheduler versus actor
  ownership, demand/buffering, error/completion and cancellation semantics in both directions.
  Avoid duplicate state or silent loss of events; a successful value conversion does not prove
  lifetime or ordering parity. Adopt or replace a reactive framework only for an approved benefit.
- Inspect callers and consumers, not only the edited async function. Include lifecycle, error
  propagation, shared state, tests and compatibility with the project's supported toolchain.

Select static and runtime checks proportionate to the change and current permission. Do not run
builds, tests or concurrency diagnostics merely because this route mentions them. When they are
not authorized or not observed, report compile/runtime behavior as unverified.
