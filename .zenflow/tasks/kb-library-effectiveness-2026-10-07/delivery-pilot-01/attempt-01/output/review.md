# Cancellation ownership review — DEV-C01

Scoped read-only review completed; source is NOT_READY against the explicit generic-cancellation contract. Evidence level E1 only. This is not a production-readiness or current-screen race verdict.

Scope: exactly three named blobs at commit `9eca97b8cfff96a14084b564b1fefd949c93d232`; all Git blob IDs, SHA256 values and byte lengths match input. No current working-tree source was read. Frozen payload selected via KNOWLEDGE_ROUTER, task-only ON authorization; no actual project handler was queried or changed. Canonical Level 0 + bounded iOS review/concurrency rules applied; review and concurrency supporting payload routes selected. No source or payload changes.

## F1 — P2 CONFIRMED: CancelBag discards members without requesting cancellation

Location: `CountriesSwiftUI/Utilities/CancelBag.swift:19-21`, storage API `:28-32`, Task conformance `:35`; cancellation consumer `CountriesSwiftUI/Utilities/Loadable.swift:42-55`.

Violated invariant: the task explicitly requires cancellation of each stored generic Cancellable, including externally retained members. `cancel()` executes only `subscriptions.removeAll()`. It guarantees that this bag stops retaining its stored handles, not that their `cancel()` methods are invoked. An empty bag is harmless. For a finite bag containing an externally retained conforming reference whose `cancel()` records a request, removing the bag reference cannot deinitialize that object and no invocation exists on this path. Its cancellation counter remains unchanged. This is a static counterexample, not an executed test. A deinitialization-cancelling wrapper may happen to cancel when its last reference is released; that cannot establish the generic contract. Dropping a Task handle likewise does not request Task cancellation.

Reachability: any Cancellable can call `store(in:)`; `Loadable.isLoading` carries a CancelBag; `cancelLoading()` dispatches to that bag. The async loader stores an actual Task at `Loadable.swift:126`; nonnil image loading reaches that loader at `ImagesInteractor.swift:25-31`. No unreachable private implementation assumption is needed. External retention is expressly inside the approved input envelope. Whether a current screen invokes cancelLoading is UNKNOWN.

Impact/severity: P2 confirmed abstraction-level ownership/cancellation failure; no evidence of a P0/P1 production incident. Cancellation-request consumers can continue work after the caller requested cancellation. Target behavior: invoke cancellation on every stored member, then relinquish bag storage; preserve the existing public ownership/signature contract. Remediation order: first fix this cancellation boundary in a separately authorized implementation phase. No patch was produced.

## O1 — CONFIRMED publication capability; current-screen race UNKNOWN

Location: `Loadable.swift:115-127`, especially success `:121` and failure `:123`; immediate cancellation state `:46-52`.

The loader creates an unstructured Task, starts .isLoading, then awaits an arbitrary async throwing resource. There is no cancellation check or operation-ownership check before either Binding write. `cancelLoading()` immediately restores `.loaded(last)` when a previous value exists, otherwise publishes a localized user-cancellation `.failed`; outside .isLoading it does nothing. Neither branch invalidates the Task's subsequent writes.

Static ordering witness, even without parallel execution: load starts and resource suspends → caller requests cancelLoading while .isLoading → cancellation state is published → resource returns a value → line 121 publishes `.loaded(value)` over that state. If the resource throws instead, line 123 publishes `.failed(error)`, including a CancellationError if thrown. Thus both success and generic failure can publish after cancellation. Cancellation request and producer completion are distinct events. Fixing F1 alone would not prove suppression: a resource can ignore cooperative cancellation or throw after it. Main-actor serialization would not prevent this ordering across suspension.

Reachability: the generic loader accepts such a resource directly; `RealImagesInteractor` reaches it for nonnil URLs. The named source does not include ImagesWebRepository implementation or screen/cancellation caller, so actual transport cancellation behavior, current UI replacement/dismissal events and visible impact are UNKNOWN. A nil URL directly publishes .notRequested; the stub does nothing. Those facts do not establish a current production defect or hidden fallback.

No extra product requirement that producer replacement exists is assumed. Treat O1 as a confirmed API capability and cancellation-state protection risk, not a second demonstrated current-screen defect. If the approved consumer contract requires cancellation to preserve its state against late completion, suppression must cover both success and failure, with the real ownership model established before implementation. Do not claim a request ID or cancel call alone proves correctness.

## Coverage and limits

| Area | Scoped result |
| --- | --- |
| Product contract, authority, finite/empty/external-retention envelope | CHECKED; F1 violates explicit cancellation invariant |
| State ownership, suspension ordering, success/error/cancellation | CHECKED E1; O1 publication capability confirmed |
| Task retention/cleanup | CHECKED E1; dropping handle is not cancellation; no proven leak |
| Actor isolation, Sendable, compiler/deployment/target profile | UNVERIFIED/UNKNOWN; no compile or data-race allegation |
| Network/media | Interactor-to-resource seam CHECKED; repository cancellation, decoding/cache and cost UNKNOWN |
| Error/loading/last-value behavior | CHECKED in Loadable only; actual user presentation UNKNOWN |
| UI structure/lazy rows/render hot path/invalidation/identity/navigation | NOT_APPLICABLE to these three utility/interactor files; screen behavior outside scope |
| Persistence/migration/auth/security/privacy/logging/release/observability | NOT_APPLICABLE to task's cancellation boundary; no app-wide claims |
| Localization/accessibility/visual polish | NOT_APPLICABLE to requested cancellation review; supported locales and UI UNKNOWN |
| Code documentation | Existing source comments inspected; no documentation changes or broad style findings |
| Verification honesty | CHECKED; E2-E5 evidence unavailable |

Checks run: exact blob SHA1/SHA256/size comparisons, selected payload SHA256 comparisons, supplied canonical KB hash comparisons, static control-flow and contract reasoning. All compared hashes matched. No whole-payload hash claim: unselected payload files were not read. No full real-code recall claim.

Build/tests/Simulator/runtime/network/host/config/secrets/MCP/Git mutations/child agents: NOT_RUN, outside authorization. git diff --check NOT_RUN: no patch exists. iPad/physical-device/actual VoiceOver checks OMITTED_BY_USER. Do not interpret absent runtime verification as PASS.

Bounded verification advice for a later explicitly authorized phase: a generic externally retained cancellable should receive cancellation; empty and multiple-member bags should retain correct semantics; controlled async resources should return and throw after cancellation while the consumer observes both publication paths. These are proposals only; no tests were created or run. Establish actual screen/caller ownership before claiming or investigating current UX impact. No ritual build is needed to establish the static missing cancel invocation.

Durable docs/plan/handoff untouched under output-only scope. Canonical baseline available; its current Git revision, host facts/CODEX_HOME and usage counters UNKNOWN because not inspected. Full Library and unrelated app docs excluded. Production prompt's broad README/AGENT_RULES reads skipped under the higher-authority bounded instruction/router policy; deep concurrency reference limited to ownership/cancellation/ordering sections. No accepted-risk exception created. Context health: контекст обновлять не нужно. Model: GPT-6.1 Sol/medium, эконом.

Handoff: перечитать весь актуальный набор документации и правил для этого worktree и task-контекста.
