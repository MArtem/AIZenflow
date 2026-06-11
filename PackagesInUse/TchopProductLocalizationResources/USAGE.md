# TchopProductLocalizationResources Usage Guide

## Purpose

`TchopProductLocalizationResources` is a single-folder standalone package. Copy the whole folder when moving this capability into another project.

## Use this package for

- TchopApp product localization bundle lookup.

## Keep in the host app

- generic localization mechanics and non-Tchop product copy.

## Integration rule

1. Import `TchopProductLocalizationResources` directly where the reusable API is needed.
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
