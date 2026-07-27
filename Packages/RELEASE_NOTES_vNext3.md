# Release Notes vNext3

## Fixed

- File-backed `AppCache.removeExpired()` no longer fails the full cleanup when a single cache file
  is corrupted or unreadable.
- `AppConfiguration` no longer stores raw `String(describing: error)` in runtime metadata.
- Successful AppConfiguration refresh now clears the active failure descriptor.
- Strict concurrency verification now includes Apple-only packages on macOS.

## Added

- `UIConfigurationFailureCategory` and `UIConfigurationFailureDescriptor`.
- Corrupted cache cleanup test.
- Sanitized AppConfiguration diagnostics tests.
- Root `PACKAGE_PORTABILITY_CONTRACT.md`.
- Per-package README portability sections.
- Consolidated `PACKAGE_HARDENING_REPORT.md`.

## Migration notes

- `UIConfigurationRuntimeMetadata.lastFailureDescription` remains available as a sanitized
  compatibility value. Prefer `lastFailure` for new code.
- Package consumers should read `PACKAGE_PORTABILITY_CONTRACT.md` before copying individual
  package folders.
