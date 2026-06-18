# Testing Policy

## Required tests

Every package must have tests. The minimum useful test count depends on complexity:

```text
Small utility package: 5–8 tests
Medium infrastructure package: 10–20 tests
Large infrastructure package: 25+ tests
```

## Test types

Each package should include:

- happy path tests;
- failure path tests;
- edge case tests;
- concurrency/cancellation tests where applicable;
- privacy/sanitization tests where applicable;
- corrupted data tests for storage/cache packages;
- platform fallback tests for Apple-only packages.

## Avoid weak tests

Weak tests:

```swift
XCTAssertNotNil(manager)
```

Useful tests:

```swift
func test_refreshFailure_preservesCurrentSnapshotAndStoresSanitizedFailure() async throws { }
```

## Test doubles

Root packages must include their own test doubles if needed:

```text
MemoryStore
MockProvider
NoopReporter
FakeClock
FailingTransport
```

They must not import test helpers from sibling packages.

## Integration helper tests

Every production helper package must test:

- mapping correctness;
- sensitive data redaction;
- edge cases;
- no raw error string leakage.
