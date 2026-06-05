# TchopProductLocalizationResources

`TchopProductLocalizationResources` is a 100% single-folder standalone Swift package. You can copy this folder into a new project, open it as a Swift Package, and run its tests without copying any sibling packages from this repository.

This package is intentionally **product-specific**. It should move with TchopApp or projects that deliberately reuse this product copy. It is standalone, but it is not generic reusable infrastructure.

## Ownership

- **Package owns**: Tchop product localization resources and a minimal direct bundle lookup helper.
- **App/integration layer owns**: generic localization mechanism, locale resolution policy, missing-key policy, and feature-specific localization facade.

## Products

- `TchopProductLocalizationResources`

## Structure

```text
TchopProductLocalizationResources/
  Package.swift
  README.md
  Sources/
  Tests/
```

The package is self-contained and keeps its tests beside its source.

## Verification

Run from this folder:

```bash
swift test
```

## Portability

Required sibling packages: **None**

Copy modes:
- **Standalone copy mode:** supported.
- **Local path dependency mode:** not required.
- **Git URL dependency mode:** supported as a normal independent package.
- **Bundle copy mode:** supported, but not required.

## Cross-package integrations

`AppLocalization` integration intentionally does **not** live inside this package anymore. It is an optional host-level composition file under:

```text
../IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration.swift
```

Copy it into the app/integration target only when both `TchopProductLocalizationResources` and `AppLocalization` are present.
