# Packages Creation Standard

This document defines the required standard for every app-independent package in this SDK.

## Core principle

A package provides a **mechanism**, not a product decision.

Good package responsibility:

```text
Secure storage
Logging
Feature flags
Pagination
Connectivity
Validation
Image loading
```

Bad package responsibility:

```text
News screen state
Profile edit copy
Feed-specific routing
source-app-specific flags
Product-specific analytics domains
```

## Required root package structure

Every package must follow this shape:

```text
PackageName/
├── Package.swift
├── README.md
├── PackageContract.md
├── Sources/
│   └── PackageName/
├── Tests/
│   └── PackageNameTests/
├── Sources/<Module>/Documentation.docc/
│   └── PackageName.docc/
└── Scripts/
    └── verify_package.sh
```

## Public API rules

Public APIs must be:

- small;
- explicit;
- testable;
- documented;
- concurrency-aware;
- app-independent;
- stable enough to compose from app layer.

Prefer protocols for external behavior boundaries:

```swift
public protocol SomeManaging: Sendable {
    func perform(_ request: SomeRequest) async throws -> SomeResult
}
```

Prefer value types for configuration and requests:

```swift
public struct SomeRequest: Sendable, Equatable {
    public let id: String
}
```

## Forbidden in root packages

A root package must not contain:

- app-specific strings;
- app-specific routes;
- feature-specific models such as `NewsArticle`, `ProfileTab`, `FeedCard`;
- sibling path dependencies;
- imports of sibling packages;
- product-specific analytics keys;
- raw telemetry of URLs, headers, tokens, body text, or private user content;
- `unsafeFlags` in `Package.swift`;
- `.build`, `.swiftpm`, `xcuserdata`, `.DS_Store`, `__MACOSX`.

## Integration policy

If two root packages need to work together, do not make one depend on the other.

Create an optional helper:

```text
IntegrationHelpers/
└── PackageAFeatureBIntegration/
```

or a copyable single helper file in the app/integration target.

## Definition of Done

A package is complete only when it has:

- implementation;
- tests;
- README;
- PackageContract;
- DocC overview;
- local verification script;
- no sibling dependency;
- no app-specific logic;
- no raw sensitive telemetry;
- clean package archive hygiene.


## Multi-target note

Multi-target packages are allowed when the targets are inside the same package folder and remain app-independent. The standalone verifier requires at least one source target, at least one test target, and source-owned DocC, but it does not require every package to have exactly one target named after the package.
