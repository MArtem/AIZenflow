# AppInputFormatting Package Contract

## Identity

- Package name: `AppInputFormatting`
- Root folder name: `AppInputFormatting`
- Library product: `AppInputFormatting`
- Main target: `AppInputFormatting`
- Test target: `AppInputFormattingTests`

## Standalone Rules

This root package is single-folder standalone:

1. No `.package(path: "../...")` dependencies.
2. No `.package(url:)` dependencies.
3. No imports of sibling SDK packages.
4. No app-specific or product-specific entities.
5. No neighboring package assumptions.
6. All sources, tests, docs, and scripts live inside this package folder.

## Execution Boundary

The package performs local string transformations in memory. No file, network, database, analytics, localization, keychain, or system-service work is hidden inside async APIs. The actor engine exists as a concurrency boundary for host-owned stores and custom formatters.

## Host-Owned Responsibilities

Host apps own:

- field meaning and product-specific input policy;
- business validation;
- localized error/copy/accessibility;
- SwiftUI/UIKit binding behavior;
- persistence of values and formatting plans;
- analytics, logging and privacy redaction;
- server/API interpretation of formatted values.

## Safety Limits

- Formatter plans and pipelines are limited to 128 formatters.
- `BuiltInInputFormatter.Kind.maxLength` accepts `0...10_000`.
- Grouping size accepts `1...16`; separator length accepts `1...16`.
- `allowCharacters` accepts `1...2_048` characters.
- Revision overflow fails as `InputFormattingFailure.revisionOverflow`.
- Applied formatter count overflow fails as `InputFormattingFailure.invalidLimit`.

## Privacy Baseline

- Input text is not emitted by descriptions or diagnostics.
- Field and formatter identifiers are redacted in descriptions.
- Pattern content, separators, and allowed character sets are redacted.
- Host-specific persistence and analytics are outside this package.

## Source-Owned DocC

DocC is owned by the source target:

```text
Sources/AppInputFormatting/Documentation.docc/AppInputFormatting.md
```

Root-level DocC catalogs are not used.

## Verification

`Scripts/verify_package.sh` uses a worktree-local scratch path outside the package folder:

```text
WorktreeScratch/AppInputFormatting
```

It does not use `/tmp`, `${TMPDIR}`, `TMPDIR`, `/Users/Artem/Library`, or any global scratch path. It cleans scratch/build artifacts after verification and fails when SwiftPM emits `warning:` or `error:` lines.
