# ``AppSecureStorage``

Product-neutral secure storage contracts and implementations for iOS infrastructure SDKs.

## Overview

`AppSecureStorage` provides a small, standalone abstraction for storing sensitive values. It intentionally avoids app-specific session, networking, analytics, or localization decisions.

Use it as a root package when you need:

- Keychain-backed storage on Apple platforms.
- Actor-backed in-memory storage for tests.
- Async secure storage contracts.
- Sanitized errors.
- Codable convenience helpers.

## Topics

### Core Contract

- ``SecureStorageManaging``
- ``SecureStorageKey``
- ``SecureStorageNamespace``

### Save Options

- ``SecureStorageSaveOptions``
- ``SecureStorageAccessibility``
- ``SecureStorageAuthenticationPolicy``

### Implementations

- ``KeychainSecureStorage``
- ``InMemorySecureStorage``

### Errors and Records

- ``SecureStorageError``
- ``SecureStorageRecord``



## Security hardening notes

`KeychainSecureStorage` routes synchronous Keychain operations through a private actor worker. Requested local authentication is fail-closed: if an access-control object cannot be created, the save operation throws `.accessControlCreationFailed` instead of silently downgrading protection. Replacement writes update existing items in place when possible and only use delete/add for synchronizable-scope changes. Key and namespace descriptions are fully redacted and do not include deterministic hashes.
