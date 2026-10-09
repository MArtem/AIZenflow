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
