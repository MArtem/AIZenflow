# AppInputFormatting

## Summary

`AppInputFormatting` is a standalone Swift package for reusable user-input formatting mechanics: safe field/formatter identifiers, input snapshots, cursor mapping, built-in formatters, formatter pipelines, and an actor formatting engine.

## Status In This Repository

Reusable package candidate reviewed from `InfrastructureSDK_Iteration23`. Adoption target is the reusable package vault unless a host app has a current input-formatting requirement.

## What Problem It Solves

- Prevents text-formatting logic from being duplicated inside SwiftUI views or feature-specific view models.
- Keeps cursor/selection mapping explicit after formatting transformations.
- Provides reusable formatting primitives without owning business validation, persistence, analytics, localization, or app-specific form policy.
- Keeps diagnostics privacy-safe by redacting input values, patterns and identifiers from descriptions.

## What It Does

- Defines safe `InputFieldID` and `InputFormatterID` identifiers.
- Represents input text and character-offset selection using `InputSnapshot` and `InputTextSelection`.
- Maps original cursor offsets to formatted cursor offsets with `InputCursorMap`.
- Provides built-in formatters for trimming, whitespace collapse, decimal digits, allow-lists, ASCII case conversion, max length, grouping and simple patterns.
- Composes formatters with `InputFormattingPipeline`.
- Runs store-backed plans through `AppInputFormattingEngine`.
- Provides an in-memory actor store for runtime wiring, tests and previews.

## When To Use It

- a text field needs repeatable formatting such as card numbers, phone-like grouping, uppercase codes, max length, whitespace cleanup or input allow-lists;
- cursor position must remain predictable after formatting;
- multiple screens/apps need the same product-neutral formatting mechanics;
- the host app wants formatting separate from form validation and UI rendering.

## When Not To Use It

- the feature only needs one direct `String` transformation;
- the behavior is business validation, localized error copy, database persistence, analytics, server-side rules or design-system UI;
- formatting depends on product-specific domain semantics that should stay in the app layer;
- a formatter would hide user-data handling, telemetry, secrets or backend policy.

## Ownership Boundary

The package owns formatting mechanics only. Host apps own field meaning, localized copy, business validation, persistence, analytics, privacy policy, UX decisions, accessibility announcements and server/domain rules.

## Products And Targets

- **Library product**: `AppInputFormatting`
- **SwiftPM target**: `AppInputFormatting`
- **Test target**: `AppInputFormattingTests`
- **Repository path when vaulted**: `./PackagesForReuse/AppInputFormatting`

## Local SwiftPM Usage

Use this when the package folder is available locally:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppInputFormatting")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppInputFormatting"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppInputFormatting`.

## Remote SwiftPM Usage

SwiftPM requires `Package.swift` at the root of the Git repository it consumes. To use this package by URL, publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppInputFormatting.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppInputFormatting"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package becomes needed by TchopApp:

1. Keep the reviewed package in `./PackagesForReuse/AppInputFormatting`.
2. Copy/sync it into `./PackagesInUse/AppInputFormatting` only when app code uses it now.
3. Add required source files through `./scripts/migrate_packages_in_use_project.py` or an equivalent deterministic project edit preserving `PackagesInUse/AppInputFormatting` grouping.
4. Keep product-specific input policy and UI behavior in `./TchopApp`.
5. Run project verification after source-only wiring.

## Basic Usage

```swift
import AppInputFormatting

let fieldID = try InputFieldID("checkout.cardNumber")
let digitsID = try InputFormatterID("digits")
let groupingID = try InputFormatterID("grouping")

let store = InMemoryInputFormattingStore()
try await store.save(formatter: try BuiltInInputFormatter(id: digitsID, kind: .allowDecimalDigits))
try await store.save(formatter: try BuiltInInputFormatter(id: groupingID, kind: .grouped(groupSize: 4, separator: " ")))
try await store.save(plan: try InputFormattingPlan(fieldID: fieldID, formatterIDs: [digitsID, groupingID]))

let engine = AppInputFormattingEngine(store: store)
let snapshot = try InputSnapshot(
    fieldID: fieldID,
    text: "4111-1111-1111-1111",
    selection: .caret(at: 19)
)
let result = try await engine.format(snapshot)
```

## Safety And Limits

- Formatter plans and pipelines are limited to 128 formatters.
- `maxLength` accepts `0...10_000`.
- Grouping size is limited to `1...16`; separator length is limited to `1...16`.
- Character allow-lists are limited to `1...2_048` characters.
- Formatter revision overflow fails with `InputFormattingFailure.revisionOverflow`.
- Applied-formatter count overflow fails with `InputFormattingFailure.invalidLimit`.
- Descriptions redact input text, identifiers, patterns and allow-lists.

## Verification

From this package folder, run:

```zsh
./Scripts/verify_package.sh
```

For source-only app integration, also run the host app's required verification:

```zsh
plutil -lint ./TchopApp.xcodeproj/project.pbxproj
./scripts/verify.sh low
git diff --check
```

## More Documentation

- `./PackageContract.md`
- `./REUSE.md`
- `./USAGE.md`
- `./Sources/AppInputFormatting/Documentation.docc/AppInputFormatting.md`
- `./Docs/Iteration23_Report.md`

## Documentation Maintenance

Every future update must keep this README, `PackageContract.md`, `REUSE.md`, `USAGE.md`, DocC and `./PackagesForReuse/PACKAGE_CATALOG.md` aligned.
