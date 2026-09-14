# Concurrency Gate
- [ ] Swift 6 strict concurrency diagnostics clean for touched code.
- [ ] Mutable state has explicit owner/isolation.
- [ ] Cross-actor values are truly Sendable.
- [ ] No unjustified @unchecked Sendable / nonisolated(unsafe) / detached tasks.
- [ ] Cancellation propagates.
- [ ] Actor reentrancy considered around every await that spans invariants.
- [ ] Task lifetime tied to owner or intentionally process-long.
- [ ] UI mutations occur on correct actor.
