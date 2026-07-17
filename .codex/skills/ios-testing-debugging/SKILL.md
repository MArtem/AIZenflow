---
name: ios-testing-debugging
description: Use for iOS or Swift verification design and diagnosis involving Swift Testing, XCTest, deterministic tests, flaky tests, UI automation, LLDB, sanitizers, Memory Graph, crash or hang triage, xcresult, and regression evidence. Trigger for test-framework decisions or difficult runtime diagnosis.
---

# iOS Testing And Debugging

## Required Context
Read:

- `./docs/IOS_TESTING_STRATEGY.md`
- `./docs/knowledge/global/ios/TESTING_DEBUGGING_AND_DIAGNOSTICS.md`
- the current task's test/build/device permissions

## Workflow
1. State the claim or symptom, environment, earliest incorrect state, and evidence already available.
2. Select the cheapest evidence that can falsify the leading hypothesis.
3. Choose unit, component, integration, UI, snapshot, property/fuzz, performance, or manual/device coverage from the failure mode.
4. Control clocks, randomness, scheduling, files, locale, network, and global state where they affect determinism.
5. Preserve failing evidence before changing code.
6. Verify the invariant and state every unexecuted gate.

## Guardrails
- Do not create or modify tests without explicit task authorization.
- Do not replace event synchronization with arbitrary sleeps.
- Retrying a flaky test gathers evidence; it does not make the test pass.
- Simulator evidence does not prove hardware or release behavior.
- Redact secrets and personal data from attachments and result artifacts.

## Output
Report hypothesis, evidence choice, reproduction, root cause or uncertainty, regression strategy, environment, and residual gaps.
