# AppCache Usage Guide

## Purpose

`AppCache` is a single-folder standalone package. Copy the whole folder when moving this capability into another project.

## Use this package for

- generic file/local cache entries, expiration metadata, and cleanup behavior.

## Keep in the host app

- domain cache keys, quota policy, and user-visible refresh decisions.

## Integration rule

1. Import `AppCache` directly where the reusable API is needed.
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
