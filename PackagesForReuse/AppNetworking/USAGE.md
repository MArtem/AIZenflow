# AppNetworking Usage Guide

## Purpose

`AppNetworking` is a single-folder standalone package. Copy the whole folder when moving this capability into another project.

## Use this package for

- request models, URLSession execution, retries, auth refresh coordination, cancellation, and HTTP failure context.

## Keep in the host app

- endpoint semantics, DTO mapping, auth/session product behavior, and UI messages.

## Integration rule

1. Import `AppNetworking` directly where the reusable API is needed.
2. Do not add app-local wrappers around package APIs unless there is a concrete lifecycle, test, or target-composition seam.
3. If behavior is generic and entity-agnostic, extend this package and keep tests in this package folder.
4. If behavior is product-specific, keep it in the app and document the boundary near the app composition point.

## Verification

From this package folder:

```bash
./Scripts/verify_package.sh
```

From the repository root:

```bash
./Packages/verify_single_folder_standalone.sh
./Packages/verify_everything.sh
```
