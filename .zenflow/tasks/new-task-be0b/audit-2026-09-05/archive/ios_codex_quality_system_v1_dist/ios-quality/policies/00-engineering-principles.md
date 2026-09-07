# 00 — Engineering Principles

## Mandatory principles

1. **Correctness before cleverness.** Prefer code whose invariants are obvious and compiler-checkable.
2. **Evidence before confidence.** A plausible patch is not a verified patch.
3. **Minimal blast radius.** Change only what is necessary to satisfy the task and its correctness requirements.
4. **Make invalid states difficult or impossible.** Prefer enums/typed states over loosely coupled booleans and optionals when the domain has a finite state machine.
5. **Single ownership of mutable state.** Every mutable state item needs one authoritative owner; other layers observe, derive, or request changes.
6. **Explicit boundaries.** UI, domain behavior, persistence, networking, security, and external dependencies should have understandable boundaries even when the project is not “Clean Architecture.”
7. **Failure is part of the design.** Network errors, cancellation, migration failures, missing permissions, empty data, invalid input, and partial availability are normal states to design for.
8. **Concurrency is an ownership model.** Async syntax alone does not make code safe. Know the actor/isolation domain, task owner, lifetime, cancellation and shared-state rules.
9. **Preserve user data.** Never use deletion/recreation as an automatic recovery strategy for persistent-store migration failures.
10. **No silent safety downgrade.** Do not weaken compiler checking, ATS, privacy declarations, tests, or warnings to “make it work.”
11. **Repository conventions matter.** Prefer the project’s established patterns when they are safe and current enough; do not impose a favorite architecture without need.
12. **Review the resulting diff, not the intention.** The patch is the product.

## MUST

- Every code-changing task MUST have explicit acceptance criteria.
- Every non-trivial task MUST identify likely failure modes before implementation.
- Every new asynchronous workflow MUST define cancellation/lifetime behavior.
- Every new dependency or version update MUST go through the dependency approval gate.
- Every new user-visible behavior MUST account for error/loading/empty states when applicable.
- Every completed task MUST report what was actually verified and what was not.

## SHOULD

- Prefer value types for immutable/domain data where identity/reference semantics are not required.
- Prefer compiler-enforced guarantees to comments and conventions.
- Prefer structured concurrency over unrelated unstructured tasks.
- Prefer dependency injection at real external/side-effect boundaries over global singletons.
- Prefer small public APIs and internal implementation details.
- Prefer deterministic tests over timing-dependent tests.

## MAY

- Use pragmatic local architecture in small features when the more abstract design would add complexity without reducing risk.
- Refactor adjacent code only when required to make the requested change safe/testable, and include that reasoning in the change plan.
