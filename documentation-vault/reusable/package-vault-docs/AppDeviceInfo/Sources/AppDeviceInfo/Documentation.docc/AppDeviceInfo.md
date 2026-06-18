# AppDeviceInfo

Create a privacy-aware device/runtime snapshot without binding your app to analytics, logging, crash reporting or diagnostics vendors.

## Overview

`AppDeviceInfo` provides standalone value types and providers for generic device information:

- platform;
- device family;
- model identifier;
- architecture;
- operating system version;
- execution environment;
- screen info;
- power and thermal state;
- physical memory availability.

The package intentionally avoids app-specific support payloads and raw diagnostic dumps.

## Basic Usage

```swift
let provider = DefaultDeviceInfoProvider()
let snapshot = await provider.snapshot()
let diagnostics = DeviceInfoDiagnostics(snapshot: snapshot)
```

## Testing

Use `StaticDeviceInfoProvider` or smaller static providers to keep tests deterministic.

## Privacy boundary

Raw `DeviceInfoSnapshot` values can be fingerprintable because they may include model identifiers, architecture, screen dimensions, memory class and OS version. Keep raw snapshots local to app composition, compatibility decisions, diagnostics screens, or tests. Do not send raw snapshots to analytics, logs, crash metadata or backend diagnostics by default. Use `DeviceInfoDiagnostics` when a privacy-safe summary is enough.
