# AppErrors

`AppErrors` is a 100% single-folder standalone Swift package. You can copy this folder into a new project, open it as a Swift Package, and run its tests without copying any sibling packages from this repository.

## Ownership

- **Package owns**: generic app-facing error semantics, severity/recovery/category contracts, presentation payloads, message catalog protocol, fallback mapper, error reporting protocol, documentation, and package-owned tests.
- **App/integration layer owns**: mapping from concrete infrastructure/domain errors, product-specific user copy, localization, telemetry policy, and flow-specific recovery behavior.

## Products

- `AppErrorsCore`
- `AppErrors`

## Structure

```text
AppErrors/
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

Networking-specific error mapping intentionally does **not** live inside this package anymore. It is an optional host-level composition file under:

```text
./PackagesForReuse/IntegrationHelpers/AppErrorsNetworkingIntegration
```

Copy it from `./PackagesForReuse` into the app/integration target only when both `AppErrors` and `AppNetworking` are present.


## Usage guide

See `./USAGE.md` for package/app boundary rules and host integration guidance.
