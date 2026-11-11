# Testing, Debugging, And Diagnostics

## Load When
Use for verification design, Swift Testing/XCTest, UI automation, deterministic testing, flaky tests, crash diagnosis, LLDB, sanitizers, memory graph, result bundles, or test migration.

## Evidence Model
Choose evidence from the claim and failure mode. Compilation proves type and availability compatibility for the built target. A passing unit test supports only the behavior actually asserted under its fixtures; it may pass for the wrong reason. A Simulator run does not prove hardware, biometrics, locked-device, camera, microphone, thermal, or real-network behavior.

## Test Portfolio
- Unit: pure decisions, mapping, validation, reducers/state machines, algorithms.
- Component: feature owner with controlled dependencies and persistence/network fakes.
- Integration: real serialization, database, files, URL protocol/server fixture, app extensions, keychain where feasible.
- UI: critical user journeys with known launch state and deterministic fixtures, accessibility identifiers, navigation/presentation, system handoffs where automation is reliable.
- Snapshot: stable visual contracts with controlled locale, content size, OS/toolchain, appearance, and fonts.
- Property/fuzz: parsers, validators, codecs, state machines, and invariants over broad input.
- Performance: measured budgets with representative data and controlled environment.
- Manual/device: hardware, permissions, lifecycle, accessibility experience, release, and environmental behavior.

Prefer changed-behavior and credible negative-path coverage over a raw percentage. Assertions must
identify the violated behavior; merely repeating implementation logic is weak evidence. Include
readability and maintenance cost when deciding which checks add useful signal. Semantic UI
identifiers alone do not establish accessibility.

## Swift Testing And XCTest
Use Swift Testing for suitable new unit/integration tests and parameterized behavior. Keep XCTest for UI tests, performance APIs or legacy areas that need it. Migrate incrementally; avoid duplicate tests that assert the same behavior indefinitely.

- Make actor isolation explicit; do not assume a test runs on the main actor.
- Use traits/tags for ownership and selection, not to hide unreliable tests.
- Use confirmations or event streams instead of sleeps.
- Parameterize meaningful cases and keep failures diagnosable.
- Attach bounded artifacts that help diagnose failures without leaking secrets.

Where supported by the actual project/toolchain, `@Test` declares cases; `#expect` records a failed
expectation while a failing `#require` throws. Select assertion/early-stop behavior from the tested
contract, rather than copying conventions without understanding their failure behavior.

Changing framework/conventions needs separately approved scope and actual project/toolchain
benefit. Preserve required CI reporting, traits/tags and unsupported framework-specific behavior.
Verify the owning target, test plan, destination, configuration and affected consumers; a passing
unit target does not prove app/extension build or resource loading.

## Parallelization Boundary Example
Swift Testing normally runs tests concurrently. A suite's `.serialized` trait serializes that
suite's descendants; it does not serialize unrelated suites or promise a deterministic
invocation order. On a parameterized test it serializes that test's cases, while on a
non-parameterized test it has no effect. Use the actual
framework/toolchain behavior rather than inferring process-wide exclusion from an annotation.

For example, two suites writing the same fixture database can still race when only one suite
is serialized. Give each test an owned store/root, or establish the genuinely shared resource's
approved synchronization contract. A useful permitted regression runs the competing owners
and verifies isolated data, rather than asserting that a trait is present. This is a design
example, not permission to add tests or an executed concurrency result.

Primary theory: [Running tests serially or in parallel](https://developer.apple.com/documentation/testing/parallelization).

## Determinism
Inject clocks, dates, UUID/random sources, locale/calendar/time zone, file roots, network transport, and schedulers where their variability affects behavior. Use temporary directories inside the approved sandbox. Reset global/process state and avoid test ordering dependencies.

Concurrency tests should control events, not hope for scheduling. Assert final state and explicit synchronization points. A global serial executor can aid diagnosis but must not conceal production races.

Fixture stores and file roots have isolated state and cleanup; parallel tests must not collide.
Generated parser/state-machine/serialization boundary cases retain a reproducible seed/input.
Snapshot comparisons control locale, text size and device traits with justified tolerances.
Performance comparisons record warmup, baseline and variance under comparable conditions; noisy
thresholds must not turn environment variance into a regression.

## Test Doubles
- Fake: working simplified implementation with controlled state.
- Stub: fixed response for a narrow interaction.
- Spy: records interactions when collaboration is the contract.
- Mock: strict expected interaction; use sparingly because it couples tests to implementation.

Prefer observable outputs and state over internal call counts. Contract tests should verify that a fake and real adapter share required semantics.

## Flaky Tests
Quarantine only with owner, issue, reason, and expiry. Capture seed, environment, repetition count, timing, simulator/device, and result bundle. Diagnose shared state, time, async completion, animation, network, locale, resource pressure, and order dependence. Retrying CI may gather evidence; it must not redefine failure as success.

Label a plausible flaky-test cause as a hypothesis until observed. Recommend bounded repeat runs
or another discriminating check only when the evidence is worth its cost and execution is authorized.

For parallel/sharded verification, account for every selected shard and terminal result against
the exact target/configuration and allocated runtime. Isolate shared state and preserve diagnostic
retry/failure history when merging results. A missing shard is not a complete passing run;
record each retry result with its own scope instead of rewriting the original failure.
Execution/allocation requires current permission.

## Debugging Workflow
1. Preserve exact symptom, environment, build, input, and timeline.
2. Reduce to the first incorrect state or earliest meaningful error.
3. Form one falsifiable hypothesis.
4. Choose the cheapest observation that distinguishes it.
5. Change one variable, reproduce, and retain evidence.
6. Fix the invariant, add regression evidence when allowed, and remove diagnostic noise.

After a supported root-cause finding, identify an observed regression detector or reproduction
path. If neither is observed, keep the diagnosis provisional and record the missing evidence.

## Tools
- LLDB: symbolic/exception breakpoints, watchpoints, thread/task backtraces, expression evaluation with caution.
- View Debugger: hierarchy, clipping, ambiguity, unexpected hosting/containment.
- Memory Graph: cycles, unexpected roots, leaked view models/controllers/tasks.
- Address Sanitizer: memory corruption and use-after-free in supported configurations.
- Thread Sanitizer: dynamic data-race evidence; compatibility and coverage are limited.
- Undefined Behavior Sanitizer and Main Thread Checker: targeted runtime diagnostics.
- Instruments: Time Profiler, Allocations, Leaks, Hangs, SwiftUI, Core Data, Network, Energy, signposts.
- `xcresult`: structured failures, attachments, diagnostics, coverage, and CI artifacts.

## Crash And Hang Triage
Symbolicate with matching binary and dSYM. Identify exception/signal, crashed thread or task, last app frame, lifecycle state, memory pressure, and preceding logs. For hangs, capture multiple samples to distinguish deadlock, actor/queue starvation, synchronous I/O, layout, and expensive main-thread work.

Connect crash/hang evidence to the affected versions/profiles, matching build UUID/binary/dSYM
and relevant frame/thread/task ownership, lifecycle and isolation. Record the regression range
and controlled reproduction where observed. A single top frame, aggregate count or visibly frozen
screen is not a supported root cause; compare falsifiable hypotheses before a speculative fix.

## Evidence Completion
- Record proposed, permitted, written, executed, failed and deferred checks separately. Denied,
  unavailable or omitted evidence never becomes PASS; disclose quarantined cases and do not
  create a hidden test substitute.
- State what was and was not executed.
- Record target, configuration, OS/runtime, device/simulator, locale, and data fixture where material.
- Preserve failing evidence before modifying the system.
- Do not create or change tests without task authorization.
- A passing suite does not waive manual/device/release gates required by the behavior.

## Primary Sources
- [Apple: Expectations and confirmations](https://developer.apple.com/documentation/testing/expectations)
- [Swift Testing](https://developer.apple.com/documentation/testing)
- [XCTest](https://developer.apple.com/documentation/xctest)
- [Diagnosing issues using crash reports and device logs](https://developer.apple.com/documentation/xcode/diagnosing-issues-using-crash-reports-and-device-logs)
- [Instruments](https://developer.apple.com/documentation/xcode/instruments)

Review after Swift Testing/XCTest changes, new diagnostic tooling, CI migration, or repeated flaky/crash classes.

## Awaited completion recipes

Select when a test starts work that can finish after its lexical scope. This section refines the
existing determinism rule; it does not prescribe a test framework migration or grant execution.

`confirmation` counts events during its async body; it is not an XCTest-style wait-until mechanism.
Register/start the producer inside that body, then await a real operation completion or an explicit
callback-lifetime barrier before the body returns. For a callback API that returns before callbacks
end, awaiting registration alone is insufficient. A controlled actor/event stream or a reviewed
exact-once continuation bridge may provide the barrier. `Task.yield()` is not that barrier.

This minimal Swift Testing sketch has one stored, awaited operation and no scheduler assumption:

```swift
import Testing

@Test func awaitedEvent() async {
    await confirmation("owned operation completes") { confirmed in
        let operation = Task { confirmed() }
        await operation.value
    }
}
```

It illustrates only confirmation lifetime, not an SDK bridge or concurrency-safety certification.
For `expectedCount: 0`, delimit and await the full relevant operation/registration lifetime; returning
immediately proves only that no event happened before return. A timeout bounds a failed wait; it
must not be treated as proof that no callback can ever occur later.

| Behavior | Controlled recipe | Required falsification |
| --- | --- | --- |
| Debounce/backoff/TTL | Inject the clock/sleeper and current-time source actually used by the owner; signal wait registration before advancing time; await the observable terminal step. | Advancing just before/at the boundary distinguishes no action from one action; cancellation removes pending work. |
| Late obsolete result/error | Capture invocation completion snapshots; complete current then obsolete producer, awaiting each; inspect final state. | Removing the relevant publication guard makes the test fail. |
| Callback cancellation | Drive callback-before-return, cancel-before-handle-assignment, duplicate and late callbacks through the real adapter. | A double completion, lost cancellation handle or leaked registration is observed, not inferred from a mock count. |
| Fixture lifetime | Install per-test store/root and teardown; await owned work before deleting it. | A competing test cannot read or delete this test's data. |

Do not add an external clock library solely for a test; reuse an existing seam or the smallest
explicit time dependency. A global serial executor, broad `.serialized`, retries or longer sleeps
must not conceal a production ordering defect. Property/generated cases retain a seed and the
smallest failing input. Use bounded test time limits supported by the actual runner, plus owned
operation cancellation/cleanup; a timeout is not safe teardown of an uncooperative producer.

Primary source reviewed2026-10-25:
[confirmation lifetime](https://developer.apple.com/documentation/testing/confirmation(_:expectedcount:isolation:sourcelocation:_:)-5mqz2).
The sketch and framework semantics require verification on the actual adopted test runner;
the standalone publication fixture tests ordering, not Swift Testing runner integration.

## Small KB regression corpus

Use only when changing an owning rule/example or explicitly evaluating KB behavior. It is not a
universal startup read, app-test requirement, model benchmark or authority to run checks. The
knowledge/testing owner maintains this set; add cases for a concrete escaped mistake rather than
increasing a coverage count. Keep expected decisions separate from observed answers.

| ID / input | Required decision | Failing answer / control | Owning section |
| --- | --- | --- | --- |
| KB-C01: old search error arrives after current success | Current result remains; await both controlled completions. | Old error becomes visible. | Concurrency: Invocation Publication Practical Slice |
| KB-C02: A→B→A inputs and first A completes last | Distinct invocation authority despite equal query. | Equality of query accepts the first A. | Same slice |
| KB-C03: old defer runs while replacement is pending | Replacement handle survives and is cancellable. | Cleanup clears the owner's current handle. | Same slice |
| KB-C04: required teardown on cancellation | Await bounded teardown; cancellation remains meaningful afterward. | Unawaited Task is called completed cleanup. | Toolchain: Swift 6.4 adoption cards |
| KB-T01: confirmation body returns before callback | Await operation/registration terminal barrier in the body. | Confirmation itself is called a waiting API. | Awaited completion recipes |
| KB-D01: in-memory migration succeeds | File-backed old-store/new-process preservation remains unverified. | In-memory PASS becomes migration durability PASS. | Persistence: Migration |
| KB-B01: checksum matches downloaded binary | Byte identity only; review publisher/code/license/slices separately. | Checksum is called trusted provenance. | Build: Dependency Identity And Slice Example |
| KB-E01: raw test artifact has been deleted | Retain scoped recorded result, mark raw evidence unavailable. | Link is still presented as reproducible raw proof. | Testing: Evidence lifecycle |

Score each observed answer per case: PASS only if the required decision is explicit and the failing
answer is absent; FAIL for the listed false-success conclusion; UNKNOWN for omitted/ambiguous output.
Record input, observed answer, expected owner/source revision, reviewer and result. Do not score a
curated expected-answer table against itself as successful agent behavior. No new model comparison
or closed experiment follows from this corpus.

Executable subset: append [PublicationChecks.swift](examples/PublicationChecks.swift) to the exact
Swift fence under Illustrative Owner Example. Compile with the adopted Swift6 profile, run all six
controlled scenarios, then separately remove success guard, generic-error guard and old-cleanup
identity check in disposable copies. Each negative must compile and fail its relevant assertion;
a compilation error, crash, timeout or unrelated failure is not a detected behavioral regression.
Keep both ordinary and default-MainActor profiles when supported. Type-checking against the minimum
iPhone Simulator SDK target is source compatibility evidence, not a Simulator run.

[CleanupChecks.swift](examples/CleanupChecks.swift) is a separate Swift6.4 host probe for awaited
cleanup and masked cancellation observation. It deliberately self-cancels only its owned test task.
It does not implement a resource transaction, iOS18 fallback or a production cleanup adapter.
For reruns, extract the owning Swift fence into an approved derived directory and append the
fixture; invoke the installed compiler with `-parse-as-library -swift-version 6 -warnings-as-errors`
and an approved `-module-cache-path`. Store source digests, exact command/profile, exit status and
bounded diagnostics. Execute only with current permission; do not download a toolchain or package.

## Fixture versus ordinary-composition evidence

Select for UI/integration fixtures, launch-environment overrides or test seams. Keep a compact
composition delta with the scenario: production consumer, substituted provider/store, launch key,
configuration, network/file/indexing side effects disabled, accessibility/lifecycle overrides,
cleanup owner and the exact claims still exercised through real adapters.

| Fixture boundary | What its PASS may establish | Separate evidence needed for the broader claim |
| --- | --- | --- |
| Offline stub → real view/owner | Visible loading/error/retry/navigation for the supplied responses. | Ordinary dependency construction, real transport/auth mapping and failures. |
| In-memory store → real repository | Query/mapping/transaction behavior inside that container. | File durability, migration, relaunch and cross-process ownership. |
| Forced lifecycle/accessibility state | UI workflow under that declared state. | Normal lifecycle propagation or accessibility exposure without the override. |
| Launch-only seeded data | User interaction with the seed and cleanup behavior. | Import, media decoding, asynchronous loading or publishing not actually exercised. |

Use the smallest ordinary-launch control when the fixture replaces a release-critical composition
path: launch without fixture keys in the relevant supported configuration, observe initial state
and the affected boundary. Run it only with current permission; if unavailable, narrow the claim
rather than silently calling the fixture production-equivalent. Release exclusion of test seams
needs target/conditional-compilation evidence; a Debug UI PASS alone is insufficient.

Keep fixture flags explicit, default-off and restricted to the intended test/Debug surface. Never
open the user's real database or reconcile real files/Spotlight while pretending to use an isolated
fixture. Give stores/domains/files unique owned identifiers and clean only those identifiers after
all owned operations finish. A passing normal control does not extend to unselected features.

## Evidence lifecycle

Resolve `DOC:EVIDENCE_BASED_ENGINEERING_RULES.md` through the active task router and select
Evidence lifecycle and cleanup before raw results/log cleanup or reuse. A recorded scoped test result and current raw-artifact
availability are independent. Preserve compact identity/result/limits and deletion status; do not
present a deleted xcresult/log as inspectable proof or silently rerun tests to recreate it.
