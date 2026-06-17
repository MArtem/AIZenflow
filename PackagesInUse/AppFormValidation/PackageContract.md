# AppFormValidation Package Contract

## Purpose

`AppFormValidation` provides standalone form validation primitives that can be copied into any Swift project as a single folder package.

## Standalone rules

This package must remain independent:

1. No `.package(path: "../...")` dependencies.
2. No remote `.package(url:)` dependencies.
3. No imports of sibling Infrastructure SDK packages.
4. No app-specific or product-specific entities.
5. No UI, analytics, logging, networking, database, or backend coupling.
6. All sources, tests, docs, and scripts must live inside this package folder.
7. DocC must remain source-owned at `Sources/AppFormValidation/Documentation.docc/AppFormValidation.md`.

## Validation boundary

Built-in rules cover local deterministic checks. Host-owned checks can be added through `FormValidationRule`. Persistence is represented by `FormSnapshotStore`; root package storage is intentionally limited to an in-memory actor.

## Privacy and security baseline

- Field values must not appear in descriptions or debug descriptions.
- Raw identifiers must not appear in diagnostics.
- Host-specific display strings should stay outside this package.
- The package must not log raw validation input.
- Security or privacy protections must not be silently downgraded.

## Verifier contract

`Scripts/verify_package.sh` must be executable and fail fast. It must use a worktree-local scratch path outside the package folder:

```bash
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_ROOT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"
```

The verifier must clean the scratch path and must not leave package-local build artifacts.

## Concurrency and state contract

`FormStateController` is the package-owned convenience runtime for one form. It must serialize load/update/save and load/validate operations even when the provided `FormSnapshotStore` suspends, because actor isolation alone does not prevent reentrant interleaving across `await` points.

`FormSnapshot.revision` is monotonic and must fail with `FormValidationFailure.revisionOverflow` instead of overflowing. A missing persisted snapshot is `FormValidationFailure.missingSnapshot`; a missing field inside an existing snapshot remains `FormValidationFailure.missingField`.

## Localization and copy boundary

This package must not contain product-specific validation messages. `FormValidationCode` and `FormValidationIssue` are stable machine-readable outputs. Host apps own localization, accessibility phrasing, field labels, and support text.
