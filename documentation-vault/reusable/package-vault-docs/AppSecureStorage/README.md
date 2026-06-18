# AppSecureStorage

`AppSecureStorage` is a 100% single-folder standalone Swift package that provides product-neutral secure storage contracts and implementations for iOS/macOS/tvOS/watchOS projects.

## Purpose

Use this package when an app needs to store small sensitive values such as tokens, user secrets, device-bound identifiers, or encrypted key material.

The package provides mechanisms only. It does **not** define app-specific keys like `accessToken`, `refreshToken`, `userID`, or product-specific session semantics.

## Contents

- `SecureStorageManaging` — async secure storage protocol.
- `SecureStorageKey` — product-neutral key wrapper with privacy-safe diagnostics.
- `SecureStorageNamespace` — optional key namespace helper.
- `SecureStorageSaveOptions` — accessibility, synchronizable, and local authentication policies.
- `SecureStorageAccessibility` — Keychain-style accessibility levels.
- `SecureStorageAuthenticationPolicy` — optional user presence / biometry policy.
- `SecureStorageRecord` — stored data + guaranteed metadata.
- `SecureStorageError` — sanitized error model.
- `InMemorySecureStorage` — actor-backed implementation for tests/previews.
- `KeychainSecureStorage` — Keychain-backed implementation on Apple platforms with a private actor execution boundary; unsupported-platform placeholder elsewhere.

## Installation / copy mode

This package is intentionally standalone:

```text
AppSecureStorage/
├── Package.swift
├── README.md
├── PackageContract.md
├── Sources/
├── Tests/
├── Docs/
└── Scripts/
```

You can copy only the `AppSecureStorage` folder into another project and open it as a Swift Package.

## Usage

```swift
import AppSecureStorage

let storage: any SecureStorageManaging = KeychainSecureStorage(
    service: "com.example.app.secure-storage"
)

extension SecureStorageKey {
    static let accessToken = SecureStorageKey("auth.access-token")
}

try await storage.save(
    Data("secret-token".utf8),
    for: .accessToken,
    options: SecureStorageSaveOptions(
        accessibility: .afterFirstUnlockThisDeviceOnly
    )
)

let tokenData = try await storage.data(for: .accessToken)
```

### Codable values

```swift
struct SessionTokens: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
}

try await storage.save(SessionTokens(accessToken: "a", refreshToken: "r"), for: "session.tokens")
let tokens = try await storage.value(for: "session.tokens", as: SessionTokens.self)
```

## What belongs here

- Secure storage contracts.
- Keychain-backed storage.
- In-memory test storage.
- Sanitized secure storage errors.
- Key validation.
- Small Codable convenience helpers.

## What must not belong here

- Product-specific keys.
- Auth/session logic.
- Networking token refresh logic.
- App-specific logout cleanup.
- Analytics/logging adapters.
- Product copy/localization.

Cross-package composition belongs in optional integration helpers.

## Security notes

- `InMemorySecureStorage` is not secure and is only for tests/previews/ephemeral use.
- `KeychainSecureStorage` is the production Apple-platform implementation.
- Keychain `SecItem*` calls are synchronous, so this package routes them through a private actor worker before touching Keychain.
- A requested local-authentication policy must not silently downgrade; access-control creation failure is reported as `.accessControlCreationFailed`.
- Values saved with per-call `synchronizable: true` remain discoverable/removable through normal read/delete APIs because lookups use an any-synchronizable query policy.
- Replacement saves update an existing Keychain item in place when possible; delete/add is reserved for synchronizable-scope changes that Keychain cannot update in place.
- Error messages intentionally avoid exposing raw keys, values, service names, access groups, URLs, or OS debug strings.
- `SecureStorageKey.description` and `SecureStorageNamespace.description` are fully redacted and do not expose stable hashes by default.
- Large values should not be stored in Keychain. Store only small secrets and references.

## Verification

```bash
./Scripts/verify_package.sh
```
