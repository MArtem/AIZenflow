# Reusing AppInputFormatting

## Copy Mode

Copy the whole `AppInputFormatting` folder into the target project's package area, keeping these files together:

- `Package.swift`
- `README.md`
- `PackageContract.md`
- `USAGE.md`
- `Sources/AppInputFormatting`
- `Tests/AppInputFormattingTests`
- `Sources/AppInputFormatting/Documentation.docc`
- `Scripts/verify_package.sh`

Do not copy generated `.build`, `.swiftpm`, `Package.resolved`, logs, DerivedData, `.DS_Store`, `__MACOSX`, or `xcuserdata` artifacts.

## Local SwiftPM Mode

```swift
.package(path: "../Packages/AppInputFormatting")
```

Link the `AppInputFormatting` product into the target that owns UI/form/input policy.

## Remote SwiftPM Mode

Publish the package folder as the root of its own Git repository, then use:

```swift
.package(url: "https://github.com/<org>/AppInputFormatting.git", from: "0.1.0")
```

SwiftPM cannot consume this package by URL from a nested subfolder of a larger app/documentation repository.

## Host App Responsibilities

The host app owns:

- actual field semantics;
- localized copy and accessibility announcements;
- validation and business rules;
- persistence of field values;
- analytics/telemetry/redaction policy;
- UI binding and debounce behavior;
- deciding which formatters apply to which fields.

## Verification After Copy

Run:

```zsh
./Scripts/verify_package.sh
```

Then run the host project's build/test/static checks after wiring the package.
