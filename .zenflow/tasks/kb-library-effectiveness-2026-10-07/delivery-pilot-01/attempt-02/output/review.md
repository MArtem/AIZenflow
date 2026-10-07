# Scoped read-only cancellation review — DEV-C01

Result: QUALITY_REVIEWED at E1 (static source reasoning), with two confirmed abstraction findings. Source is the three exact Git blobs at `9eca97b8cfff96a14084b564b1fefd949c93d232`; current checkout content was not read. This is review completion, not code acceptance, runtime verification or production readiness.

## Contract and scope

Task contract: every stored generic `Cancellable` must receive an explicit cancellation request; handle disposal alone is insufficient. Any finite bag, empty bags and externally retained members are included. Cancellation request, rejection of obsolete publication and stopping/undoing producer work are distinct promises. Bindings publish Loadable state; nonnil image requests delegate into that API. No source/signature/product behavior changes or patches were authorized.

Docs route: canonical bootstrap + Level 0 (only sibling task handoff/plan) + bounded review/concurrency standards. Supplied payload was selected through KNOWLEDGE_ROUTER under explicit task-only ON authorization. Actual project mode and handlers remain uninspected. Relevant supporting routes: review and concurrency; after source facts, CXL-01 was read before final finding adjudication. Its example and historical 8/8 claim are not validation of this source.

## F1 — P2: Generic stored members receive no cancellation request

**Exact locations:** `CountriesSwiftUI/Utilities/CancelBag.swift:19–21`, generic storage at `:12` and `:28–32`; caller `CountriesSwiftUI/Utilities/Loadable.swift:42–55`.

**Evidence / violated invariant:** `CancelBag.cancel()` only executes `subscriptions.removeAll()`. No member's `cancel()` is called. `cancelLoading()` invokes this bag method while `.isLoading`; therefore it guarantees removal of stored handles, not a cancellation request to every generic member.

**Reachability:** the public-to-module `Cancellable.store(in:)` appends any conforming value, including a reference object still retained by its producer/caller. A member whose cancellation effect occurs only in `cancel()` remains uncancelled after its bag reference is discarded. This is a source-level counterexample admitted explicitly by the task's input envelope, not an executed test. A Task also enters the bag from `LoadableSubject.load` at Loadable.swift:126 using CancelBag.swift:35. Dropping a task handle does not establish task cancellation.

**Impact / calibration:** confirmed API-contract failure; P2 within the supplied abstraction contract. Actual screen impact, cancellation cooperation of ImagesWebRepository and occurrence rate are UNKNOWN. Some `AnyCancellable` objects may cancel on final deallocation, but that conditional behavior cannot establish the generic guarantee, especially with external retention. Empty bags satisfy the requirement vacuously.

**Target behavior / order:** first ensure cancellation explicitly invokes each stored member's cancellation API and then releases ownership, preserving the existing finite-bag API. This requests cancellation; it does not prove work stopped or side effects rolled back. No patch proposed or applied.

**Evidence needed for a later authorized fix:** a retained generic member receiving cancellation, multiple members and empty bag; real Task cancellation request. No test or runtime work was performed here.

## F2 — P2: Both terminal publications can overwrite cancellation state

**Exact locations:** `CountriesSwiftUI/Utilities/Loadable.swift:115–127`, especially `:121` (success) and `:123` (generic failure); cancellation state transitions at `:44–53`. Concrete supplied entry is `CountriesSwiftUI/Interactors/ImagesInteractor.swift:25–31` for nonnil URL.

**Evidence / reachability:** `load` assigns `.isLoading` with a new bag, creates an unstructured Task, awaits the arbitrary supplied resource and unconditionally assigns `.loaded(value)` or `.failed(error)`. It has no post-await cancellation or operation-identity check. A permitted sequence is: load starts → resource suspends → caller cancels the same binding → resource returns → `.loaded` overwrites the cancellation transition. If the resource throws instead, `.failed(error)` overwrites it. These sequences require no overlapping memory access: sequential execution around suspension is sufficient. Fixing F1 alone still would not reject completion from a producer that ignores cooperative cancellation; even a cancellation error currently enters the generic catch and is published.

**Immediate guarantee of cancelLoading:** in `.isLoading`, bag handles are discarded; a prior `last` becomes `.loaded(last)`, otherwise `.failed(NSUserCancelledError)` is assigned. In any other Loadable state it does nothing. That immediate state is not protected from subsequent completion. Existing last-value/cancelled-error behavior is the observed contract; CXL-01's different `.cancelled` presentation is not imposed.

**Impact / calibration:** confirmed lack of abstraction-level publication protection; P2 for that contract boundary. An actual current-screen race is UNVERIFIED: no screen caller, binding storage, cancellation trigger, replacement policy, repository implementation, toolchain configuration or target membership was available in scope. Nonnil RealImagesInteractor calls establish an API consumer, not proof that a real screen reaches the failing ordering. No concrete leak, thread data race, off-main UI mutation or performance defect is asserted. The nil-input branch synchronously assigns `.notRequested`; alone it is not an async cancellation defect.

**Target behavior / order:** after F1, use the real state owner's cancellation/identity policy to reject obsolete success and generic failure at their publication boundary while preserving current genuine failures and existing cancellation presentation. Validate owner/isolation before choosing a mechanism; existing handle identity or proven serialized intake may suffice. No requirement for a new counter, architecture or producer replacement is inferred. No patch proposed or applied.

**Evidence needed for a later authorized fix:** controlled completion after explicit cancellation, both returned value and thrown generic error; true current failure remains observable. Replacement cases only if actual consumers permit replacement. Builds/tests are not currently authorized.

## Checklist and evidence limits

| Area | Status and reason |
|---|---|
| Product contract, API authority, producer/consumer | CHECKED for the supplied contract and three source files; F1/F2 |
| State/time, cancellation, failure/loading states | CHECKED at E1; both terminal publications traced |
| Architecture/ownership | Binding/Loadable/bag/Task chain CHECKED; concrete state owner and actor UNKNOWN |
| UI structure, lazy rows, render hot path, invalidation, visual cost, navigation | UNVERIFIED app-wide; no screen code in scope, no screen findings |
| Identity/domain shape | Invocation identity is absent at publication; unrelated model identity not applicable to this scope |
| Persistence/files/durable side effects | NOT_APPLICABLE to the named implementation; producer internals UNKNOWN; no rollback claim |
| Network/offline/sync | Nonnil image delegation CHECKED; transport cancellation/retry/offline internals UNKNOWN |
| Memory/media/cache/resource lifetime | Handle release and task capture CHECKED; cache, downsampling, bound of producer lifetime UNKNOWN |
| Security/privacy/logging | No sensitive logging/storage in the three inspected blobs; project security/privacy UNVERIFIED |
| Accessibility/localization | No UI inspected; existing cancellation string uses NSLocalizedString; translation coverage UNKNOWN |
| Lifecycle/observability/release/compatibility | UNVERIFIED outside exact source scope; compiler/language/SDK settings UNKNOWN |
| Verification honesty | CHECKED: E1 only, no execution evidence inferred |

Checks run: read exact blobs with numbered source lines; compare blob SHA, SHA-256 and bytes; compare selected frozen payload and supplied canonical KB hash pins. All matches recorded in ledger. Source/payload bytes were preserved by read-only operations. Builds, tests, test writing, type-check, Simulator, Instruments, runtime, network, MCP, host/config/secret access and Git mutations: NOT_RUN/NOT_PERFORMED. iPad, physical-device and actual VoiceOver checks: OMITTED_BY_USER. `git diff --check` NOT_RUN: no source patch or Git write authorized. Current screen recall and full real-code recall UNKNOWN; no oracle-based TP/FP score claimed.

Scope completed: one fresh bounded read-only review. Files changed: only output/review.md and output/ledger.json. Durable rules and task plan/handoff unchanged under explicit own-output-only boundary. Known F1/F2 remain unfixed; no READY_FOR_USER_REVIEW, READY_FOR_PR or production-ready code claim. Local exceptions: no new ADR; task-only payload ON selection is the explicit trial authorization. Context health: контекст обновлять не нужно. Model result: GPT-6.1 Sol/medium, эконом, one executor. Context-transfer rule: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
