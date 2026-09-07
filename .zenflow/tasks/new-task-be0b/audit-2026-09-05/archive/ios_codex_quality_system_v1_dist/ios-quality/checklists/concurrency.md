# Concurrency Checklist

- [ ] What isolation domain owns each mutable state?
- [ ] Does any value cross actor/task boundaries? Is Sendable correct?
- [ ] Any `Task` has owner/lifetime/cancellation defined.
- [ ] Structured concurrency used where parent-child lifetime exists.
- [ ] `Task.detached` justified if present.
- [ ] Every `await` in actor state logic reviewed for reentrancy.
- [ ] CPU-heavy work is not accidentally MainActor work.
- [ ] Stale completion cannot overwrite newer state.
- [ ] CancellationError is not treated as ordinary failure.
- [ ] Long custom loops check cancellation.
- [ ] No unjustified `@unchecked Sendable`, `nonisolated(unsafe)`, `@preconcurrency`.
- [ ] Stored Task/closure ownership checked for retain cycle.
- [ ] TSan/runtime diagnostics considered for R3+.
