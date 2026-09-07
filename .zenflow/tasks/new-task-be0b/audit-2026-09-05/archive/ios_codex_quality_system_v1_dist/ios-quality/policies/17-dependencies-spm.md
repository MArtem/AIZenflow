# 17 — Dependencies and Swift Package Manager

## Human approval

Any add/remove/update of a dependency requires explicit user approval before mutation, unless the user already explicitly requested that dependency action.

## Dependency review MUST answer

- Why is the dependency necessary instead of platform/existing code?
- Is it source or binary?
- Who maintains it and is development/release activity healthy enough for project needs?
- License compatibility?
- Minimum deployment/toolchain compatibility?
- Transitive dependencies?
- Security/privacy implications?
- Privacy manifest/signature requirements for App Store submission?
- Size/build-time/runtime impact?
- Exit strategy if the package becomes unmaintained?

## Version requirements

Prefer semantic version requirements appropriate to stability needs. Avoid branch dependencies for released production apps unless there is a documented temporary reason. Commit-hash dependencies are exceptional and should be temporary/documented.

## Package.resolved

For application/CI reproducibility, commit `Package.resolved` where the project’s workflow expects it. CI SHOULD disable automatic resolution/use resolved versions to prevent unreviewed dependency drift.

Any unexpected `Package.resolved` diff is a gate failure until explained.

## Binary dependencies

Binary dependencies receive extra scrutiny because source cannot be inspected/rebuilt. Verify authenticity/signing/fingerprint behavior supported by Xcode/SwiftPM and review vendor security/privacy posture.

## Plugins/macros

Build-tool plugins and macros execute code during build/compilation workflows. Treat newly introduced plugins/macros as supply-chain/code-execution review triggers.

## API changes in packages

For libraries/packages with external clients, consider SwiftPM API-breaking-change diagnostics/symbol graph comparison as part of public API gates.
