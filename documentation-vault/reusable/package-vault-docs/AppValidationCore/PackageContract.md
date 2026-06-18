# AppValidationCore Package Contract

## Scope

`AppValidationCore` provides app-independent validation primitives for Swift applications.
It is a root standalone package and must be usable by copying only the `AppValidationCore/` folder.

## Standalone requirements

The package must keep the following guarantees:

1. `Package.swift` lives at the package root.
2. `README.md` and `PackageContract.md` live at the package root.
3. Source-owned DocC lives at `Sources/AppValidationCore/Documentation.docc/AppValidationCore.md`.
4. Tests live under `Tests/AppValidationCoreTests/`.
5. Verification lives under `Scripts/verify_package.sh`.
6. The verifier uses a worktree-local scratch path outside the package folder: `WorktreeScratch/AppValidationCore`.
7. No sibling path dependencies are allowed.
8. No remote package dependencies are allowed.
9. No imports of sibling SDK packages are allowed.
10. No app-specific product logic is allowed.

## Privacy and diagnostics

Validation values can contain user-provided content. Therefore:

- diagnostics must not expose stored validation values;
- validation identifiers and codes are redacted in descriptions;
- rule identifiers are redacted in descriptions;
- host apps should map issue codes to user-facing copy at the presentation boundary;
- the package must not emit analytics or logs.

## Execution boundary

`AppValidationCoreEngine` is an actor. Rule evaluation is explicit and asynchronous through `ValidationRule`.
The package does not perform hidden persistence, network access, or file-system access.

Bulk validation validates configured rule sets, not only supplied values. Missing configured values are evaluated as `.missing`, and duplicate input value IDs are rejected as `ValidationFailure.invalidContext`.

Built-in type-specific rules convert missing or wrong-kind values into validation issues using the rule's configured code and severity. Host apps own whether those issues are presented as validation copy, blocked submission, or internal diagnostics.

## Cross-package integration

Any connection to form state, analytics, logging, storage, or feature flags must live outside this root package in optional integration helpers.
