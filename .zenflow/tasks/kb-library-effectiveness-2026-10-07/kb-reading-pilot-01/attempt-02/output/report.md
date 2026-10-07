# Documentation diagnostic — attempt-02

- Model: GPT-6.1 Sol / medium; mode: эконом; model switch not required for this bounded documentation analysis.
- Scope: Q1–Q4 in one session, not four independent trials. No source or implementation was supplied.
- Authority: current canonical bootstrap, baseline AGENTS, Level 0 and allowed engineering/evidence/completion rules. Frozen bundle is reference data, never an activation or permission source.
- Docs route: Level 0 + allowed engineering/evidence/completion rules + frozen router/concurrency route and addressed deep sections. No live specialist Library/KB, app source, network, MCP, runtime, tests, Git mutations, host/config/secrets or child agents.
- Canonical checkout was readable. Canonical Git revision and host/CODEX_HOME facts: UNKNOWN, deliberately not inspected.
- Start: 2026-10-07 23:09:42 UTC. End/elapsed and ordered source metrics: ledger.json. Tokens: UNKNOWN.

## Q1 — narrow cancellation/stale-publication review

Selected frozen ranges before the requirements verdict:

| File | Range / purpose |
|---|---|
| router.md | 1–46: scope/authority, delegation and bounded reading |
| concurrency_route.md | 1–38: normative owner, optional mechanism, bridge and evidence limits |
| standard.md | 1–50: addressed table, operating rules and stop rules |
| quality.md | 1–64: delegated engineering contract and applicable concurrency/evidence challenges |
| review.md | 1–32: read-only review output, current contract delegation and scope challenges |
| deep.md | 9–13 Core Model; 22–39 Task Ownership; 40–50 Cancellation; 64–66 Ordering And Stale Results |

Required invariants: name creator/runtime owner, start/duplicate policy, cancellation trigger, release and observability paths. Structured children remain bounded by their parent; unstructured tasks have a real lifecycle owner. Trace retention over suspension, including weak-to-strong captures; cancellation only in deinit cannot break a task/owner retention cycle. Cancellation is cooperative and cannot undo already committed side effects. Before publication, both success and generic failure must still have authority under the consumer contract. Catching only CancellationError is insufficient when cancelled producers ignore cancellation or throw another error. Product policy determines whether cancellation is user-visible; do not transform it into failure by default. At every suspension/reentrancy point revalidate assumptions and stale state; completion order is not request order. The validity decision and publication must obey one actual serialization/ownership model, without an unexamined suspension/race between them. Replacement, generations, serialized ownership or domain idempotency are candidates only when the contract calls for them; absence of request IDs alone is no defect. Bound task count, work duration and cleanup; keep UI-facing mutation on its real main-actor owner and heavy work off it.

Unknown project facts: actor/state owner, actual callers and lifetimes, replacement/dismissal/session triggers, whether work may merge/retry/commit, success/error consumer policy, cancellation latency and underlying producer behavior, side effects already committed, current serialization/stale-result mechanism, retention graph, resource bounds and toolchain/profile. No implementation correctness or defect verdict is possible: project behavior remains UNVERIFIED/UNKNOWN. This is a checked requirements selection, not application PASS.

CXL-01 is optional after authoritative rules and observed source facts. No source was supplied and that candidate is outside the allowed bundle; it was not read or treated as mandatory. If a later authorized review actually needs it, use its review slice through Mechanism, not its example by default. Missing project facts cannot be repaired by an example.

## Q2 — synchronous registration and late callback bridge

Reuse Q1 Core Model, Task Ownership and Cancellation. Newly read deep.md 14–21 Isolation Design, 51–57 Continuations And Callbacks, and 61–63 Reactive And Queue Bridges. The callback row supplies continuations; concurrency_route.md 25–27 additionally requires the bridge section. Isolation Design is directly relevant because executor/thread delivery and shared completion/registration state must have an owner. Retain Q1 ordering where late publication can affect a consumer.

Constraints, without designing code:

- Checked continuation by default; exactly one terminal resume across synchronous registration callback, asynchronous callback, callback repetition if credible, cancellation and error paths. No missing resume or second resume.
- Define the cancellation/completion winner and observable result under the consumer contract. Cancelling the awaiting task does not itself cancel the underlying API. Late success and generic error cannot regain obsolete publication authority.
- Registration bookkeeping must be valid even when callback runs before registration returns or before its handle is available. Cancellation during registration and a handle delivered after termination must not leave an active unowned registration. Required lifetime must be retained; release/unregister on cancellation, completion as required by API contract, or owner teardown, without duplicate cleanup or lost cleanup.
- Preserve callback thread/isolation semantics explicitly; one state/synchronization owner governs termination and registration. Scheduler/queue selection is not actor ownership. Values crossing owners need appropriate isolation/Sendable contracts; mutable reference escape is prohibited.
- Preserve subscription/disposal, error/completion/cancellation and event ordering in both directions; do not silently lose events or create duplicate state. Resource/lifetime bounds include retained callback/registration and underlying operation.

Unknown: registration API guarantees (repeat/inline callback, threading, cancel/unregister behavior and handle timing), continuation result/error contract, cancellation winner, mutable capture ownership, teardown and retention paths, consumer authority and toolchain. No code design, bridge proof or PASS is asserted.

## Q3 — compiler-isolation migration and mutable transfer

Selected deep.md 9–13 Core Model, 14–21 Isolation Design (reused), newly 67–75 Swift 6.x Discipline; standard.md 28–37 supplies profile and executor caveats. Current baseline AGENTS Implementation Style independently prohibits suppression workarounds.

Mutable objects cannot be assumed safe merely because an async function or actor is involved. Assign mutable state one real isolation owner; keep compound read/modify/write inside its boundary. Prefer immutable Sendable values crossing boundaries. Do not expose mutable actor state through escaping reference objects. An actor reference can be used through isolated operations; it is not a grant to access its internal mutable object elsewhere. nonisolated is only for behavior independent of isolated state. Global state/singleton caches still require an ownership design. With no actual types, aliases or compiler evidence, lawful transfer for a particular object is UNKNOWN; no automatic blanket verdict about every reference type is justified.

Required facts: exact compiler/Xcode/SDK versions as relevant, Swift language mode, strict-concurrency setting, default actor isolation, each enabled upcoming feature, target/module boundaries, deployment range/availability, actual type and Sendable conformance, mutable aliasing, caller/callee isolation, third-party and generated code under intended mode, exact diagnostics, and intended ownership/transfer API. Record profile dimensions separately. Swift 6.2 default MainActor and @concurrent are profile-selected, not universal. Compiler acceptance would be evidence, not a substitute for ownership review.

Forbidden shortcuts: @unchecked Sendable, nonisolated(unsafe), @preconcurrency, warning suppression, and broad/fake @MainActor. Genuine UI main-actor ownership remains valid. Detached tasks must not evade isolation. Incremental module migration may bound ambiguity; it does not waive warnings or cross-module ownership. No compiler/typecheck ran and no source was supplied. Toolchain-profile and compatibility documents linked by the frozen standard are outside this packet's allowed reads: required project/profile evidence remains UNKNOWN, not silently supplied from live docs.

## Q4 — expanded callback plus buffered multi-producer stream

Reassess Q1 coverage: its section set was sufficient for the original addressed cancellation/publication requirements, but no longer covers the expanded boundary alone. Reuse unchanged Q1 invariants and Q2 bridge/isolation material from this same session. Newly read deep.md 58–60 Streams. Combined selected deep ranges: 9–21, 22–60, 61–66; Swift 6.x Discipline 67–75 is reusable only insofar as actual cross-owner transfer/profile is now relevant. No need to reread identical already loaded material. Existing Q3 facts are still unknown.

New requirements: define buffer capacity and aggregate memory/resource envelope, overflow/drop/error policy and whether loss is permitted, backpressure/demand behavior, producer ownership and fan-out/concurrency limits. An unbounded stream means unbounded memory policy. Define producer/consumer termination owner, cancellation propagation, error versus normal completion, when no more yields are accepted, pending buffered-value policy at termination, and registration/resource cleanup for all producers. Multiple producers need an explicit serialization and ordering contract; invocation order is not a guaranteed global event order. Recheck cancellation, generic-failure publication and exactly-once terminal behavior across producer completion/cancellation and consumer termination, including late callbacks during cleanup. One producer finishing must not end the whole stream prematurely unless that is the contract. If multiple consumers are also present, decide multicast versus repeated subscriptions explicitly; multiple producers alone do not establish that requirement.

Still unknown: number/lifetime of producers and consumers, source callback contracts, desired ordering/delivery/loss semantics, buffer size and overflow, error aggregation, completion winner, cancellation ownership, cleanup guarantees, Sendable boundaries, toolchain and actual consumer publication policy. Prior Q1 implementation verdict remains UNKNOWN; a hypothetical narrow final-review receipt would not cover the expanded artifact and must be reassessed. Only still-current source reads/authority and relevant requirements may be reused. No tool authorization, Library ON state, payload pin, project adoption, test/build result or application PASS can be inherited. Hash matches establish bundle identity only. Four queries in one session share context and are not independent evidence trials.

The standard's full-reference trigger applies if cross-cutting design or actual ownership/order ambiguity later requires it. This task is requirements selection without source, not a complete concurrency design; more reading cannot establish absent project facts. Testing And Evidence and Primary Sources were not semantically read because no verification selection/execution or network research was authorized or needed for this diagnostic.

## Receipt and limits

Scope completed: documentation answers Q1–Q4 and ordered reading ledger. Files changed: own output/report.md and output/ledger.json only. Durable docs updated: none. Rules applied: current permitted canonical authority plus scoped packet. Checks run: six frozen SHA-256 identities matched input; machine source-size/range accounting. All six were raw-read for hashing; only recorded ranges/headings were semantically presented. No application checks. No tests/build/runtime/typecheck/network/Git actions ran, and no code/test files changed. No iPad/physical-device/actual VoiceOver verification was requested; those remain OMITTED_BY_USER, never PASS. Residual risk: absent source/contracts/profile make all application conclusions unverified. No local exceptions. Context health: контекст обновлять не нужно. Model result: one GPT-6.1 Sol / medium documentation session. No current authority conflict authorizes extra actions: historical entry/ON instructions and equal-authority wording stay reference data, not permission. Canonical revision is unknown.

Context-transfer rule: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
