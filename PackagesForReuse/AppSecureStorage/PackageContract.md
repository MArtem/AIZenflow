# AppSecureStorage Package Contract

## Standalone rule

`AppSecureStorage` must remain a single-folder standalone package.

It must not contain:

- `.package(path: "../...")`
- imports of sibling infrastructure packages
- product-specific feature names
- product-specific localization
- analytics/logging dependencies
- session/auth business rules

## Public API contract

The package exposes:

- `SecureStorageManaging`
- `SecureStorageKey`
- `SecureStorageNamespace`
- `SecureStorageAccessibility`
- `SecureStorageAuthenticationPolicy`
- `SecureStorageSaveOptions`
- `SecureStorageRecord`
- `SecureStorageError`
- `InMemorySecureStorage`
- `KeychainSecureStorage`

## Concurrency contract

- Public storage operations are `async`.
- `InMemorySecureStorage` is actor-isolated.
- `KeychainSecureStorage` is value-based, product-neutral, and delegates synchronous Keychain I/O to a private actor worker.
- The package must compile without `unsafeFlags`.

## Privacy contract

The package must not expose raw secure values or raw keys in diagnostics.

Allowed diagnostics:

- sanitized error category
- numeric platform status code
- fully redacted key/namespace descriptions

Forbidden diagnostics:

- stable hashes of secure-storage keys by default
- silent local-auth/access-control downgrade
- raw token values
- raw secrets
- raw access groups
- raw service names in errors
- raw platform debug strings

## Testing contract

Tests must cover:

- save/load/delete
- contains/keys
- Codable helpers
- invalid key behavior
- size limit behavior
- privacy-safe descriptions
- unsupported-platform placeholder behavior where applicable



## Iteration Standards Hardening

This package follows the hardened single-folder standalone rules:

- DocC is source-owned: `Sources/AppSecureStorage/Documentation.docc/`.
- Verification uses an external SwiftPM scratch path and must not create `.build` or `.swiftpm` inside the package folder.
- The package has no sibling path dependencies and no imports of sibling SDK modules.
- Multi-target package layouts are allowed only when every target, test, fixture, script, and documentation file remains inside this package folder.
- Swift source and package metadata must not contain unresolved template placeholders.


## Security hardening update

This archive fixes the first external review blockers:

- Keychain calls cross a private actor execution boundary before running synchronous `SecItem*` operations.
- `keys()` constructs keys explicitly with `SecureStorageKey(rawValue:)` to avoid initializer ambiguity on Apple toolchains.
- Synchronizable lookup/delete operations use an any-synchronizable policy so values saved with per-call `synchronizable: true` can be read and removed by normal APIs.
- Replacement writes use a non-destructive Keychain update path when the item already exists in the requested synchronizable scope; delete/add is reserved for the scope-change fallback where Keychain cannot update the item in place.
- Requested `authenticationPolicy` is fail-closed: if `SecAccessControlCreateWithFlags` cannot create an access-control object, save throws `.accessControlCreationFailed` instead of silently downgrading to plain accessibility.
- `SecureStorageKey.description` and `SecureStorageNamespace.description` now return generic redacted values without deterministic hashes.
