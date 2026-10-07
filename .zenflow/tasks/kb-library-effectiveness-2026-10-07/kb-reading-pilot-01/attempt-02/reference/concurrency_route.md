# Swift concurrency — curated copy-only route

Use after project-local rules for a change involving tasks, actors, isolation, cancellation or
asynchronous APIs. This route curates `IOS-03-01` through `IOS-03-14`; the imported files are not
independently approved for the active payload. Establish the actual Swift language mode, compiler
settings, deployment range and existing owner of mutable state before recommending a change.

For replacement/cancellation publication work, after the authoritative KB rules and observed source
facts, optionally select [CXL-01](CXL-01_CANCELLATION_PUBLICATION.md#select-before-deciding-a-change) before
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

## Normative Owner And Optional Mechanism

Use the canonical KB `IOS_CONCURRENCY_RUNTIME_STANDARD.md` and its addressed deep-reading table.
Do not repeat a completed, still-current normative read because this Library route was selected.
The KB sections own Task retention/lifetime, cancellation and generic-failure publication, isolation/
Sendable, continuations, streams, ordering and reactive/queue bridges. For a bridge task, add
Reactive And Queue Bridges to the selected deep sections; combine other rows as the actual scope requires.
Missing or stale KB material remains UNKNOWN; this route cannot substitute for the governed bootstrap
or authorize prohibited isolation suppressions, checks, dependencies or framework adoption.

For a concrete cancellation/publication mechanism unresolved by source facts and the KB, CXL-01 above
is an optional practical candidate. Its example is not a default architecture; retain an existing
serialized solution that meets the actual consumer contract. No independent benefit or project adoption
is implied by selecting it. Review this route when its KB section names or candidate mechanism change.

Select static and runtime checks proportionate to the change and current permission. Do not run
builds, tests or concurrency diagnostics merely because this route mentions them. When they are
not authorized or not observed, report compile/runtime behavior as unverified.
