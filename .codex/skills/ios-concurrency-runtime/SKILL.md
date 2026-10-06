---
name: ios-concurrency-runtime
description: Review or change iOS concurrency behavior involving async/await, Task lifetime, actor isolation, Sendable, cancellation, callback bridging, or Swift 6 diagnostics; not for an incidental mention of a task, async API, or main thread.
---

# iOS Concurrency Runtime

## Workflow
1. Identify state owners and actor boundaries.
2. Check affected async operations for owner, cancellation, error handling, and lifetime.
3. Flag heavy work inherited by the main actor.
4. Treat Swift 6 warnings as future production failures.
5. Report findings with severity, evidence, target state, and verification.

## References
- `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`
- `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`
