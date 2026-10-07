# Verification strategy — curated copy-only route

Use after project-local test rules to decide what evidence an iOS change needs. This route
curates the risk-based intent of `IOS-10-01` through `IOS-10-14`, not their generic prompts.
Test need, permission to edit tests, permission to run them, and permission to use Simulator,
device or Instruments are separate decisions. `reference ON` changes none of those permissions.

- Map each changed invariant and credible failure mode to the smallest useful observation:
  source review, focused unit test, integration/contract test, UI test, manual device check,
  relaunch/migration fixture, network failure simulation or performance measurement.
- Prefer deterministic fixtures and controlled clocks, randomness and transport. Check positive,
  negative, cancellation and partial-result paths where they carry risk. A test that merely
  repeats implementation logic or passes for the wrong reason is weak evidence.
  Synchronize asynchronous assertions on observable completion rather than arbitrary sleeps.
  Check that test doubles preserve the relevant real dependency contract and failure behavior;
  a convenient fake is not evidence of integration fidelity.
  Select fake/stub/spy by the behavior being observed, not private call choreography. Check order
  independence and parallel fixture isolation; capture relevant seed/environment for reproduction.
  Parameterize meaningful input boundaries; for parsers/state machines/serialization, recommend
  reproducible generated cases when they add signal. An assertion's failure must identify the
  violated behavior rather than merely report that an implementation detail changed.
- When investigating a flaky test, trace shared mutable state, unstructured tasks that outlive
  the assertion, clock/date/randomness, filesystem/network leakage and UI synchronization.
  Distinguish a plausible cause from an observed one; recommend a bounded repeat-run or other
  discriminating check only when its evidence is worth the cost and execution is authorized.
- Verify the actual owning target, test plan, destination, configuration and affected consumers.
  A passing unit target does not establish that an app/extension builds or that a resource loads.
  Changing XCTest/Swift Testing conventions requires actual project/toolchain benefit rather
  than novelty; preserve needed CI reporting, traits/tags and unsupported framework-specific
  features. Recommend such a migration only within separately approved scope.
- For UI or design changes, identify supported device/size, accessibility and locale observations.
  For persistence, include old-data and relaunch behavior; for network work, include timeout,
  offline, retry and error mapping. Select only relevant cases.
  UI evidence needs known launch state, stable semantic identifiers and critical user journeys;
  an identifier-only test does not prove accessibility. Snapshot comparisons need controlled
  locale/text size/device traits and justified tolerances. Performance tests need comparable
  warmup/baseline/variance, not thresholds that turn environmental noise into a regression.
  Prefer changed-behavior and negative-path coverage over a raw percentage; account for known
  flaky/quarantined cases rather than treating omitted evidence as PASS.
- Record tests proposed, permitted, written, executed, failed and deferred separately. If the
  project or user does not permit a check, do not create a substitute hidden test artifact or
  report a PASS. State the residual risk and the smallest user-run check that would resolve it.

Do not write/modify tests, invoke a build, start a simulator, profile, contact a server or run a
workflow merely because this route recommends an evidence type. A test result supports only its
observed scope and never replaces semantic review of the complete final change.
