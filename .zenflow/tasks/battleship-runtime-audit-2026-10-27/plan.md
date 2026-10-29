# Battleship runtime audit

Mode эконом; model GPT-6.1 Terra under explicit user override. ProjectID 6a655f50-2a48-49df-9b5a-bdff693564de; exact selector BattleshipGame/BattleshipGame.xcodeproj. User authorizes builds, simulator UI, Instruments, creation/modification/execution of tests and app code changes. No tools/dependency installation, signing, CI, archive, external services or Git publication. iPad, physical device and actual VoiceOver OMITTED_BY_USER. Firefox, Share and Library remain closed.

- [x] Confirm project identity, scheme, source scope and safe environment.
- [x] Map game flows and prioritize functional/performance risk.
- [x] Run permitted targeted iPhone Simulator UI scenarios and collect results.
- [ ] Capture and interpret applicable Instruments evidence for every relevant flow: PARTIAL; launch trace, hitch, fresh-shot CPU attribution and long-session memory retention remain unmeasured; XCTest launch duration, board gestures, start, reset and fresh shots have selected clock/memory observations.
- [x] Review findings and report observed/inferred/unmeasured areas; see report.md.

Runtime results cover only selected app/target/environment and not real hardware or production readiness.

## Approved continuation: validate and improve the profiling system

User intent: choose projects and bounded features independently; use user journeys as workloads to expose technical weaknesses, including leaks, rendering, hitches, threads and memory. This is a trial of the profiling system itself. Expand this checklist as evidence reveals gaps.

- [x] Define a feature-specific scenario and measurement matrix, with explicit evidence and unavailable-metric statuses (`scenario-matrix.md`; update with new evidence).
- [x] Separate clock and memory from hitch availability, retain terminal outcome, and validate movement outside each measured interval. Scroll passed on iOS 18.2 and 27; player-win attachment verified on iOS 27. Hitch remains unmeasured.
- [x] Measure New game reset separately in Release on iOS 27 and assert the board and state are cleared.
- [x] Measure the ship-orientation toggle separately in Release on iOS 27 and assert both orientation labels.
- [x] Add a separate fresh-shot clock/memory scenario; a 20-target sweep passed on iOS 27 Release, capturing 6 Hit and 14 Miss labels plus turn return. No Sunk occurred; randomized fleet and XCUITest overhead remain limitations.
- [x] Compare fresh-shot memory against state-neutral accessibility queries: 19 isolated queries had zero physical-memory change; a 500-query batch had +409.6 kB, matching the 20-shot run's +409.6 kB absolute growth. This demonstrates a measurement confound, not an allocation owner or proof of leak.
- [x] Probe Game Performance Overview during an active Release scroll workload. The app appeared in the 45.6 s trace, but its per-frame table had no rows and only nine all-process CPU samples belonged to the app; this alternative did not provide usable frame/scroll profiling evidence.
- [x] Compare all-process and app-attached Time Profiler on the Release 20-shot workload. The all-process export had unresolved app addresses and only system/automation hang rows. Direct app attachment resolved process identity/symbols, covered all 20 shots, and produced 15,024 app CPU samples, 35 app-binary frames and no app >250 ms hang rows; Accessibility/XCTest/SwiftUI dominated Main Thread stacks. This excludes a sustained hotspot at this sample resolution, not brief work or frame hitches.
- [x] Profile the paired 15-tap coordinate and accessibility-query controls with direct app attachment. Approximate tap windows show 1,471 app / 1,052 Main Thread samples for precomputed coordinates versus 2,618 / 2,121 with per-tap label queries. Treat as evidence of an automation/accessibility confound, not a precise causal or user-latency estimate.
- [x] Profile a player-win endgame and reset with direct app attachment. Release iOS 27 UI test passed with retained `You sank the Carrier and won!` outcome; the 92.693 s app trace covered the later game actions, win and reset, with 45,240 app samples (39,661 Main Thread), five `fire(at:)` and three `computerTurn()` stack occurrences, and no app >250 ms potential-hang rows. Attachment began ~19 s after shooting began; early shots are outside this profile. XCTest/accessibility frames dominate, so this did not isolate game-logic cost or frame pacing.
- [x] Review shot-path observation dependencies statically: `computerBoard` has no view consumer but is `@Published`; retain as a hypothesis only because SwiftUI coalescing and measurable impact are unresolved.
- [x] Review scoped CPU/concurrency/accessibility behavior in the model and board views. The `@MainActor` computer-turn scan is bounded by the 10×10 board; all 200 visible cells compute localized accessibility labels, a plausible source of XCTest snapshot overhead but not a demonstrated user-facing bottleneck. No unbounded work or app-owned async pipeline was found in the reviewed files; this is not a whole-target audit.
- [x] Add app-targeted `XCTCPUMetric(application:)` beside clock/memory metrics in eight manually bounded user-action intervals. The initializer passed an isolated type-check against the installed XCTest SDK.
- [ ] Collect and compare the new app CPU values on Release iOS Simulator. Runtime collection is pending: CoreSimulatorService became unavailable before tests; generic `build-for-testing` then failed with a malformed SwiftUI macro-plugin response. Do not interpret either as an app defect or as a successful build.
- [ ] If CoreSimulator remains stable, capture a paired hit/sunk path with app-targeted CPU/update evidence before considering any change to `computerBoard` publication.
- [x] Confirm both player-win and computer-win UI terminal outcomes on iOS 27 and verify New game reset after each; full endgame runs were not individually timed.
- [x] Investigate the recorded shooting hangs with lower-overhead and repeat controls; one 573 ms placement event did not reproduce, and original shooting microhangs did not recur in tested controls. Allocations totals were exported. Cause and app attribution remain unproven, so preserve as an unresolved signal rather than a confirmed defect.
- [x] Compare the 49 unattributed 32-byte Leaks objects against idle and query-only controls and inspect available stacks. Counts were 49 during cycles, one idle, and 46 during XCTest queries without game changes; stacks are truncated. Automation is a plausible alternative, not proven ownership; no app leak is confirmed.
- [ ] Record repeatable baselines and collect applicable Instruments evidence per prioritized scenario; distinguish automation effects and unmeasured parameters.
- [x] Correct and publish validated reusable process and documentation gaps in their canonical owner, following documentation governance. Prior guidance updates are `52955ead47149dd8c78001de444c3bf95f133b6a` and `da5b7240ba95ec45250ddf6520f39fd7b33afe37`; the latest outcome-branch and router fix is `789abe5da8e1162305d396f8fe9a0c24d46a3260`, pushed to `main` and remote-verified.
- [ ] Produce a first-stage findings report with evidence, uncertainty and coverage. The second stage diagnoses causes and produces a code-fix plan; the third repeats profiling to verify fixes. User authorizes app source changes.
