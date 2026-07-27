# Release Process

## Per-package release checklist

Before a package becomes part of the SDK baseline:

```text
[ ] Package.swift exists
[ ] README.md exists
[ ] PackageContract.md exists
[ ] Sources exist
[ ] Tests exist
[ ] DocC overview exists
[ ] Scripts/verify_package.sh exists
[ ] No sibling dependencies
[ ] No sibling imports
[ ] No unsafeFlags
[ ] No app-specific product logic
[ ] No raw sensitive telemetry
[ ] swift test --build-path "$BUILD_DIR" passes on supported platform
[ ] strict concurrency check passes where applicable
```

## SDK checkpoint release

Every 5–10 packages, create a checkpoint archive:

```text
InfrastructureSDK_Checkpoint_01.zip
InfrastructureSDK_Checkpoint_02.zip
```

Each checkpoint should include:

- package catalog;
- status matrix;
- integration helper catalog;
- release notes;
- hardening report;
- verification scripts.

## Final SDK release

Final release requires:

- all package tests passing;
- Apple-only packages verified on macOS/Xcode;
- strict concurrency verification;
- archive hygiene verification;
- no forbidden package dependencies;
- no raw sensitive telemetry;
- full SDK catalog generated.
