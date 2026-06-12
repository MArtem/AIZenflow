# AppDeviceInfo Package Contract

## Purpose

`AppDeviceInfo` provides product-independent device/runtime snapshot primitives for Apple-platform and portable Swift code.

It is a mechanism package. It is not an analytics package, a crash reporter, a logging package or an app-specific diagnostics exporter.

## Standalone rules

This package must remain 100% single-folder standalone:

- no `.package(path: "../...")` dependencies;
- no remote package dependencies;
- no imports of sibling SDK packages;
- all sources, tests, scripts and DocC live inside this folder;
- DocC is source-owned under `Sources/AppDeviceInfo/Documentation.docc/`;
- verification must use a worktree-local scratch path outside this package folder;
- verification must not leave `.build`, `.swiftpm`, `Package.resolved` or archive artifacts inside this folder.

## Public API ownership

The package owns:

- `DevicePlatform`;
- `DeviceExecutionEnvironment`;
- `DeviceFamily`;
- `DeviceModelInfo`;
- `OperatingSystemInfo`;
- `DeviceScreenInfo`;
- `DevicePowerInfo`;
- `DeviceMemoryInfo`;
- `DeviceInfoSnapshot`;
- `DeviceInfoDiagnostics`;
- provider protocols;
- static providers;
- default process-based provider.

## Privacy and security

The package must not expose:

- full process environment;
- full process arguments;
- user identifiers;
- advertising identifiers;
- vendor identifiers;
- raw file-system paths;
- credentials, tokens, cookies or backend secrets.

`DeviceInfoDiagnostics` is intentionally summary-oriented. It reports categories and booleans rather than full diagnostic dumps.

## Concurrency

All public value types must be `Sendable`.

Provider protocols are async-compatible and `Sendable`. Implementations must not bypass compiler-checked Sendable guarantees.

## Multi-target policy

A future multi-target split is allowed only if every target remains inside this package folder and no sibling dependency is introduced.

## Integration policy

Examples of integrations that must not live in this root package:

- `AppDeviceInfo + AppAnalytics` automatic device attributes;
- `AppDeviceInfo + AppLogging` log metadata enrichers;
- `AppDeviceInfo + AppDiagnostics` provider registration;
- `AppDeviceInfo + AppCrashReportingCore` custom keys.

Those belong in optional helper packages or host app composition code.

## Privacy boundary

Raw `DeviceInfoSnapshot` values can be fingerprintable because they may include model identifiers, architecture, screen dimensions, memory class and OS version. Keep raw snapshots local to app composition, compatibility decisions, diagnostics screens, or tests. Do not send raw snapshots to analytics, logs, crash metadata or backend diagnostics by default. Use `DeviceInfoDiagnostics` when a privacy-safe summary is enough.
