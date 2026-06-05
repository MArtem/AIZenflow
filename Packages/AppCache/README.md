# AppCache

`AppCache` is a standalone Swift package intended to move into another project as one complete folder.

## Ownership

- **Package owns**: reusable mechanisms, public contracts, documentation, and package-owned tests for the products listed below.
- **App owns**: product-specific policy, concrete feature behavior, user-facing copy, backend-specific decisions, and app composition.

## Products

- `AppCache`

## Structure

```text
AppCache/
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

## vNext2 metadata support

`LocalCacheManaging` now supports reading a full `CacheRecord<Value>` in addition to the raw value. Use this when a feature needs to reason about freshness, cache age, diagnostics, or stale-content UI.

```swift
let record = try await cache.record(forKey: "feed", as: FeedSnapshot.self)
print(record?.storedAt)
print(record?.expirationDate)
```

Expired entries can also be cleaned explicitly:

```swift
let removed = try await cache.removeExpired()
```

The raw `value(forKey:as:)` API remains the simplest path for call sites that do not care about metadata.

## Portability

Required sibling packages: **None**

Copy modes:
- **Standalone copy mode:** supported.
- **Local path dependency mode:** supported when this folder is copied with its required siblings using the same relative layout.
- **Git URL dependency mode:** supported after replacing local `.package(path:)` declarations with package URLs.
- **Bundle copy mode:** supported by copying the whole `Packages/` directory.

This package can be copied as a single folder. Use bundle copy mode if you want all packages and scripts together.


## vNext3 corrupted-file cleanup

`FileLocalCacheManager.removeExpired()` is resilient to corrupted or unreadable `.cache` files.
A single bad cache entry no longer makes the full cleanup fail. Invalid cache files are removed on
a best-effort basis and valid fresh entries are preserved.
