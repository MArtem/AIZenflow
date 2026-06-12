# AppDeviceInfo

`AppDeviceInfo` is a single-folder standalone Swift package for product-independent device and runtime diagnostics.

It answers questions such as:

- what platform is running;
- what OS version is running;
- what device family/model identifier is available;
- whether the app appears to run in unit tests, previews, simulator or physical-device mode;
- whether low-power and thermal state are available;
- whether screen and memory information are available.

The package does not contain app-specific diagnostics, analytics events, logging, crash reporting or backend configuration.

## Standalone contract

The folder can be copied independently into a new project and opened as a Swift Package.

Rules:

- no sibling path dependencies;
- no remote package dependencies;
- no imports of other Infrastructure SDK packages;
- all sources, tests, scripts and DocC live inside this folder;
- DocC is source-owned under `Sources/AppDeviceInfo/Documentation.docc/`;
- verification uses a worktree-local scratch path outside this package folder;
- verification must not create `.build` or `.swiftpm` inside this package folder.

## Usage

```swift
import AppDeviceInfo

let provider = DefaultDeviceInfoProvider()
let snapshot = await provider.snapshot()
let diagnostics = DeviceInfoDiagnostics(snapshot: snapshot)
```

For tests and previews:

```swift
let provider = StaticDeviceInfoProvider(
    snapshot: DeviceInfoSnapshot(
        model: DeviceModelInfo(identifier: "iPhone16,1", family: .phone, architecture: "arm64"),
        operatingSystem: OperatingSystemInfo(platform: .iOS, name: "iOS", versionString: "17.0.0", majorVersion: 17, minorVersion: 0, patchVersion: 0),
        executionEnvironment: .simulator,
        screen: DeviceScreenInfo(widthPoints: 390, heightPoints: 844, scale: 3),
        power: DevicePowerInfo(isLowPowerModeEnabled: false, thermalCondition: .nominal),
        memory: DeviceMemoryInfo(physicalMemoryBytes: 8_589_934_592)
    )
)
```

## What belongs here

- platform and OS snapshot types;
- model/family/architecture snapshot types;
- execution environment detection;
- power, thermal, screen and memory snapshot types;
- static and process-based providers;
- privacy-safe diagnostics summary.

## What does not belong here

- app-specific support bundle diagnostics;
- analytics event emission;
- crash reporting SDK adapters;
- logging adapters;
- remote diagnostics upload;
- backend environment selection;
- device fingerprinting.

Those belong in optional integration helpers or in the host app.

## Verification

```bash
cd AppDeviceInfo
./Scripts/verify_package.sh
```

The verifier uses a worktree-local scratch path outside the package folder and removes it after the run.

## Privacy boundary

Raw `DeviceInfoSnapshot` values can be fingerprintable because they may include model identifiers, architecture, screen dimensions, memory class and OS version. Keep raw snapshots local to app composition, compatibility decisions, diagnostics screens, or tests. Do not send raw snapshots to analytics, logs, crash metadata or backend diagnostics by default. Use `DeviceInfoDiagnostics` when a privacy-safe summary is enough.
