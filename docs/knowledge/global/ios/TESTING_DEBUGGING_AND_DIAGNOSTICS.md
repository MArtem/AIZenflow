# Testing, Debugging, And Diagnostics

## Load When
Use for verification design, Swift Testing/XCTest, UI automation, deterministic testing, flaky tests, crash diagnosis, LLDB, sanitizers, memory graph, result bundles, or test migration.

## Evidence Model
Choose evidence from the claim and failure mode. Compilation proves type and availability compatibility for the built target. A unit test proves one modeled behavior under its fixtures. A Simulator run does not prove hardware, biometrics, locked-device, camera, microphone, thermal, or real-network behavior.

## Test Portfolio
- Unit: pure decisions, mapping, validation, reducers/state machines, algorithms.
- Component: feature owner with controlled dependencies and persistence/network fakes.
- Integration: real serialization, database, files, URL protocol/server fixture, app extensions, keychain where feasible.
- UI: critical user journeys, accessibility identifiers, navigation/presentation, system handoffs where automation is reliable.
- Snapshot: stable visual contracts with controlled locale, content size, OS/toolchain, appearance, and fonts.
- Property/fuzz: parsers, validators, codecs, state machines, and invariants over broad input.
- Performance: measured budgets with representative data and controlled environment.
- Manual/device: hardware, permissions, lifecycle, accessibility experience, release, and environmental behavior.

## Swift Testing And XCTest
Use Swift Testing for suitable new unit/integration tests and parameterized behavior. Keep XCTest for UI tests, performance APIs or legacy areas that need it. Migrate incrementally; avoid duplicate tests that assert the same behavior indefinitely.

- Make actor isolation explicit; do not assume a test runs on the main actor.
- Use traits/tags for ownership and selection, not to hide unreliable tests.
- Use confirmations or event streams instead of sleeps.
- Parameterize meaningful cases and keep failures diagnosable.
- Attach bounded artifacts that help diagnose failures without leaking secrets.

## Determinism
Inject clocks, dates, UUID/random sources, locale/calendar/time zone, file roots, network transport, and schedulers where their variability affects behavior. Use temporary directories inside the approved sandbox. Reset global/process state and avoid test ordering dependencies.

Concurrency tests should control events, not hope for scheduling. Assert final state and explicit synchronization points. A global serial executor can aid diagnosis but must not conceal production races.

## Test Doubles
- Fake: working simplified implementation with controlled state.
- Stub: fixed response for a narrow interaction.
- Spy: records interactions when collaboration is the contract.
- Mock: strict expected interaction; use sparingly because it couples tests to implementation.

Prefer observable outputs and state over internal call counts. Contract tests should verify that a fake and real adapter share required semantics.

## Flaky Tests
Quarantine only with owner, issue, reason, and expiry. Capture seed, environment, repetition count, timing, simulator/device, and result bundle. Diagnose shared state, time, async completion, animation, network, locale, resource pressure, and order dependence. Retrying CI may gather evidence; it must not redefine failure as success.

## Debugging Workflow
1. Preserve exact symptom, environment, build, input, and timeline.
2. Reduce to the first incorrect state or earliest meaningful error.
3. Form one falsifiable hypothesis.
4. Choose the cheapest observation that distinguishes it.
5. Change one variable, reproduce, and retain evidence.
6. Fix the invariant, add regression evidence when allowed, and remove diagnostic noise.

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
Symbolicate with matching binary and dSYM. Identify exception/signal, crashed thread or task, last app frame, lifecycle state, memory pressure, and preceding logs. For hangs, capture multiple samples to distinguish deadlock, actor/queue starvation, synchronous I/O, and expensive main-thread work.

## Evidence Completion
- State what was and was not executed.
- Record target, configuration, OS/runtime, device/simulator, locale, and data fixture where material.
- Preserve failing evidence before modifying the system.
- Do not create or change tests without task authorization.
- A passing suite does not waive manual/device/release gates required by the behavior.

## Primary Sources
- [Swift Testing](https://developer.apple.com/documentation/testing)
- [XCTest](https://developer.apple.com/documentation/xctest)
- [Diagnosing issues using crash reports and device logs](https://developer.apple.com/documentation/xcode/diagnosing-issues-using-crash-reports-and-device-logs)
- [Instruments](https://developer.apple.com/documentation/xcode/instruments)

Review after Swift Testing/XCTest changes, new diagnostic tooling, CI migration, or repeated flaky/crash classes.
