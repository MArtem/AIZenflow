# Single-Folder Standalone Rules

## Definition

A single-folder standalone package can be copied as one folder into a new project and used without any sibling packages from this repository.

The package must work as:

```bash
cd PackageName
./Scripts/verify_package.sh
```

when platform requirements are satisfied.

## Hard constraints

### No sibling dependencies

`Package.swift` must not contain:

```swift
.package(path: "../AppNetworking")
.package(path: "../AppErrors")
.package(path: "../SomeSibling")
```

### No external package dependencies by default

For maximum portability, root packages should avoid external dependencies. If unavoidable, the dependency must be justified in `PackageContract.md`.

### No sibling imports

Sources and tests must not import sibling modules:

```swift
import AppNetworking
import AppErrors
import AppLocalization
```

unless those modules are inside the same folder as nested local implementation. The default target state is no sibling imports at all.

### Integration goes outside

Cross-package composition belongs in:

```text
IntegrationHelpers/
```

not in root packages.

## Allowed dependencies

Allowed:

- Swift standard library;
- Foundation;
- Apple frameworks required by the package domain, clearly documented;
- package-internal targets only.

Examples:

```text
AppAppleAuthentication may import AuthenticationServices.
AppDatabase may import CoreData/SwiftData.
AppHaptics may import UIKit conditionally.
```

## Package contract

Each package must explicitly state:

```text
Standalone status: yes/no
Required Apple frameworks
Required OS/platforms
Does it depend on sibling packages? no
Does it expose app-specific product logic? no
Integration helpers available: optional list
```


## Multi-target note

Multi-target packages are allowed when the targets are inside the same package folder and remain app-independent. The standalone verifier requires at least one source target, at least one test target, and source-owned DocC, but it does not require every package to have exactly one target named after the package.
