# Package Checklist

Use this checklist for every new package.

## Structure

```text
[ ] Package.swift
[ ] README.md
[ ] PackageContract.md
[ ] Sources/PackageName
[ ] Tests/PackageNameTests
[ ] Sources/PackageName/Documentation.docc/PackageName.md
[ ] Scripts/verify_package.sh
```

## Standalone

```text
[ ] No .package(path: "../...")
[ ] No .package dependencies unless explicitly justified
[ ] No imports of sibling package modules
[ ] No IntegrationHelpers inside root package
[ ] Can be copied as one folder
```

## Architecture

```text
[ ] Provides mechanism, not product decision
[ ] Public API is small and explicit
[ ] Errors are typed or normalized
[ ] Test doubles are included locally if needed
[ ] No app routes/screens/models/strings
```

## Concurrency

```text
[ ] Public cross-task models are Sendable where appropriate
[ ] Shared mutable state is protected by actor/lock/value isolation
[ ] @MainActor used only when justified
[ ] Cancellation behavior documented
[ ] No unnecessary @unchecked Sendable
```

## Privacy

```text
[ ] No raw tokens/headers/body text in logs/analytics/errors
[ ] URLs are sanitized before telemetry
[ ] Raw error string not emitted by default
[ ] Redaction tests added where applicable
```

## Testing

```text
[ ] Happy path tests
[ ] Failure path tests
[ ] Edge case tests
[ ] Corruption/fallback tests if storage-like
[ ] Cancellation/concurrency tests if async
[ ] Privacy tests if telemetry-like
```

## Documentation

```text
[ ] Purpose
[ ] What belongs here
[ ] What must not belong here
[ ] Public API examples
[ ] Thread-safety/concurrency notes
[ ] Platform support
[ ] Integration helpers
[ ] Known limitations
```


## Multi-target note

Multi-target packages are allowed when the targets are inside the same package folder and remain app-independent. The standalone verifier requires at least one source target, at least one test target, and source-owned DocC, but it does not require every package to have exactly one target named after the package.
