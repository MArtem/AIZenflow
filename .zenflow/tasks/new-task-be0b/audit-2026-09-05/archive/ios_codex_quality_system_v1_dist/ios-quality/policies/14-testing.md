# 14 — Testing

## Test philosophy

Tests are executable contracts, not a coverage-number game. New behavior should be proven at the cheapest reliable layer that can catch its likely failures.

## Frameworks

- Use the project’s established framework.
- Swift Testing is preferred for new unit/integration tests in modern compatible projects where it fits.
- XCTest remains valid and is required/appropriate for UI testing and some performance/legacy workflows.
- Mixed Swift Testing/XCTest suites are acceptable during incremental migration.

## Test pyramid / layers

Use a balanced set:

1. pure unit tests for algorithms/state transitions/mapping;
2. integration tests for module boundaries/network/persistence adapters;
3. UI tests for critical user journeys and integration behavior that unit tests cannot prove;
4. performance tests for measured budgets/regressions.

## Every bug fix SHOULD

- add a regression test that fails before the fix and passes after it, when reproducible at reasonable cost;
- document why a test is not practical if omitted for a meaningful regression.

## Async tests

MUST avoid arbitrary `sleep` as synchronization. Use async APIs, expectations/confirmations, clocks/test schedulers, continuations/fakes, or deterministic dependency control.

## Parallel safety

Swift Testing may run tests/test cases in parallel. Tests MUST NOT depend on shared mutable global state, fixed shared files/ports/accounts, or ordering unless explicitly serialized/isolation is part of the test design.

## Test doubles

Prefer focused fakes/stubs/spies that model relevant behavior. Avoid mocks so over-specified that harmless implementation refactors break tests.

## Test plans

Mature projects SHOULD maintain distinct test-plan configurations, for example:

- `Fast` targeted/unit;
- `Full` unit+integration+UI as applicable;
- `TSan`;
- `ASan`;
- `Performance` optimized configuration.

Xcode test plans can also promote runtime issues to failures.

## Sanitizers

For relevant risk areas:

- Address Sanitizer — memory corruption/use-after-free classes;
- Thread Sanitizer — thread races in Simulator/macOS-supported environments;
- Main Thread Checker — UI API misuse;
- UBSan — C-family undefined behavior where applicable.

Sanitizers are not required on every tiny patch but R3+ concurrency/memory/interoperability changes should consider them.

## Coverage

Coverage MAY guide missing-test discovery but MUST NOT be treated as proof of correctness. High-risk branches/edge cases matter more than raw percentage.

## Test modification gate

If existing test expectations change, the change plan/PR MUST explain whether:

- product behavior intentionally changed;
- the old test was incorrect;
- implementation detail was over-specified.

Never weaken tests merely to obtain green status.
