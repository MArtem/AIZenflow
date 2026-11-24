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
[ ] No @unchecked Sendable; resolve ownership and isolation according to CONCURRENCY_POLICY.md
```

## Privacy

```text
[ ] No raw tokens/headers/body text in logs/analytics/errors
[ ] URL telemetry uses an explicit allowlist/redaction policy; path/slug is not assumed safe
[ ] Raw error string not emitted by default
[ ] Redaction tests added where applicable
```

## Testing

The entries describe relevant coverage, not permission to create or run tests. Follow current
user authorization; record unavailable coverage as not verified, never as a pass.

```text
[ ] Risk-based verification for happy path where applicable and permitted
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

Multi-target packages are allowed when the targets are inside the same package folder and remain app-independent. The historical standalone verifier expected at least one source target, one test target, and source-owned DocC; it did not require every package to have exactly one target named after the package. The reviewed verifier templates are disabled pending a safe replacement. Revalidate the selected verifier and current permissions before any use; this note is not verification evidence.
