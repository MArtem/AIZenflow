import Foundation

#if canImport(Security)
import Security

/// Keychain-backed secure storage.
///
/// This type is intentionally product-neutral: callers provide a service name,
/// optional access group, and keys. It does not know auth/session/token concepts.
///
/// Keychain APIs are synchronous. Public async methods cross into a private actor
/// before touching `SecItem*`, so callers invoking this storage from `@MainActor`
/// do not execute Keychain I/O on the main actor executor.
public struct KeychainSecureStorage: SecureStorageManaging, Sendable {
    private let worker: KeychainSecureStorageWorker

    public init(
        service: String,
        accessGroup: String? = nil,
        defaultSynchronizable: Bool = false,
        maximumValueSizeInBytes: Int = SecureStorageValidation.maximumValueSizeInBytes
    ) {
        self.worker = KeychainSecureStorageWorker(
            service: service,
            accessGroup: accessGroup,
            defaultSynchronizable: defaultSynchronizable,
            maximumValueSizeInBytes: maximumValueSizeInBytes
        )
    }

    public func data(for key: SecureStorageKey) async throws -> Data? {
        try await worker.data(for: key)
    }

    public func record(for key: SecureStorageKey) async throws -> SecureStorageRecord? {
        try await worker.record(for: key)
    }

    public func save(_ data: Data, for key: SecureStorageKey, options: SecureStorageSaveOptions = .default) async throws {
        try await worker.save(data, for: key, options: options)
    }

    public func removeValue(for key: SecureStorageKey) async throws {
        try await worker.removeValue(for: key)
    }

    public func removeAll() async throws {
        try await worker.removeAll()
    }

    public func contains(_ key: SecureStorageKey) async throws -> Bool {
        try await worker.contains(key)
    }

    public func keys() async throws -> [SecureStorageKey] {
        try await worker.keys()
    }
}

private actor KeychainSecureStorageWorker {
    private let service: String
    private let accessGroup: String?
    private let defaultSynchronizable: Bool
    private let maximumValueSizeInBytes: Int

    init(
        service: String,
        accessGroup: String?,
        defaultSynchronizable: Bool,
        maximumValueSizeInBytes: Int
    ) {
        self.service = service
        self.accessGroup = accessGroup
        self.defaultSynchronizable = defaultSynchronizable
        self.maximumValueSizeInBytes = maximumValueSizeInBytes
    }

    func data(for key: SecureStorageKey) throws -> Data? {
        try SecureStorageValidation.validateKey(key)

        var query = lookupQuery(for: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw mapStatus(status)
        }

        guard let data = result as? Data else {
            throw SecureStorageError.unknown
        }

        return data
    }

    func record(for key: SecureStorageKey) throws -> SecureStorageRecord? {
        guard let data = try data(for: key) else {
            return nil
        }
        return SecureStorageRecord(key: key, data: data)
    }

    func save(_ data: Data, for key: SecureStorageKey, options: SecureStorageSaveOptions) throws {
        try SecureStorageValidation.validateKey(key)
        try SecureStorageValidation.validateValueSize(data, maximumBytes: maximumValueSizeInBytes)

        let synchronizable = options.synchronizable || defaultSynchronizable
        let attributes = try keychainAttributes(for: options, data: data)

        var addQuery = itemQuery(for: key, synchronizable: synchronizable)
        attributes.forEach { addQuery[$0.key] = $0.value }

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        if addStatus == errSecSuccess {
            return
        }

        // Prefer non-destructive updates for normal replacement writes so a failed
        // save does not erase the existing secret. Only fall back to delete/add when
        // Keychain reports a duplicate in a different synchronizable scope.
        if addStatus == errSecDuplicateItem {
            let updateStatus = SecItemUpdate(itemQuery(for: key, synchronizable: synchronizable) as CFDictionary, attributes as CFDictionary)
            if updateStatus == errSecSuccess {
                return
            }

            if updateStatus == errSecItemNotFound {
                try deleteExistingValue(for: key)
                let retryStatus = SecItemAdd(addQuery as CFDictionary, nil)
                guard retryStatus == errSecSuccess else {
                    throw mapStatus(retryStatus)
                }
                return
            }

            throw mapStatus(updateStatus)
        }

        throw mapStatus(addStatus)
    }

    func removeValue(for key: SecureStorageKey) throws {
        try SecureStorageValidation.validateKey(key)
        try deleteExistingValue(for: key)
    }

    func removeAll() throws {
        var query = serviceQuery()
        query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw mapStatus(status)
        }
    }

    func contains(_ key: SecureStorageKey) throws -> Bool {
        try SecureStorageValidation.validateKey(key)

        var query = lookupQuery(for: key)
        query[kSecReturnData as String] = kCFBooleanFalse
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecItemNotFound {
            return false
        }
        guard status == errSecSuccess else {
            throw mapStatus(status)
        }
        return true
    }

    func keys() throws -> [SecureStorageKey] {
        var query = serviceQuery()
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return []
        }

        guard status == errSecSuccess else {
            throw mapStatus(status)
        }

        guard let attributes = result as? [[String: Any]] else {
            return []
        }

        return attributes
            .compactMap { $0[kSecAttrAccount as String] as? String }
            .map { SecureStorageKey(rawValue: $0) }
            .sorted { $0.rawValue < $1.rawValue }
    }

    private func serviceQuery() -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        return query
    }

    private func lookupQuery(for key: SecureStorageKey) -> [String: Any] {
        var query = serviceQuery()
        query[kSecAttrAccount as String] = key.rawValue
        query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        return query
    }

    private func itemQuery(for key: SecureStorageKey, synchronizable: Bool) -> [String: Any] {
        var query = serviceQuery()
        query[kSecAttrAccount as String] = key.rawValue
        query[kSecAttrSynchronizable as String] = synchronizable ? kCFBooleanTrue : kCFBooleanFalse
        return query
    }

    private func deleteExistingValue(for key: SecureStorageKey) throws {
        let status = SecItemDelete(lookupQuery(for: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw mapStatus(status)
        }
    }

    private func keychainAttributes(
        for options: SecureStorageSaveOptions,
        data: Data
    ) throws -> [String: Any] {
        var attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        if let authenticationPolicy = options.authenticationPolicy {
            guard let accessControl = makeAccessControl(accessibility: options.accessibility, policy: authenticationPolicy) else {
                throw SecureStorageError.accessControlCreationFailed
            }
            attributes[kSecAttrAccessControl as String] = accessControl
        } else {
            attributes[kSecAttrAccessible as String] = options.accessibility.keychainValue
        }

        return attributes
    }

    private func makeAccessControl(
        accessibility: SecureStorageAccessibility,
        policy: SecureStorageAuthenticationPolicy
    ) -> SecAccessControl? {
        var error: Unmanaged<CFError>?
        let accessControl = SecAccessControlCreateWithFlags(
            nil,
            accessibility.keychainValue,
            policy.accessControlFlags,
            &error
        )
        error?.release()
        return accessControl
    }

    private func mapStatus(_ status: OSStatus) -> SecureStorageError {
        switch status {
        case errSecItemNotFound:
            return .itemNotFound
        case errSecAuthFailed, errSecUserCanceled:
            return .accessDenied
        case errSecInteractionNotAllowed:
            return .interactionNotAllowed
        default:
            return .keychainFailure(status: Int32(status))
        }
    }
}

private extension SecureStorageAccessibility {
    var keychainValue: CFString {
        switch self {
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}

private extension SecureStorageAuthenticationPolicy {
    var accessControlFlags: SecAccessControlCreateFlags {
        switch self {
        case .userPresence:
            return .userPresence
        case .biometryAny:
            return .biometryAny
        case .biometryCurrentSet:
            return .biometryCurrentSet
        }
    }
}

#else

/// Placeholder implementation used on platforms where Security.framework is not available.
///
/// The type exists so code can compile in portable SwiftPM environments. All operations
/// throw `.unsupportedPlatform`. Use `InMemorySecureStorage` for tests on non-Apple platforms.
public struct KeychainSecureStorage: SecureStorageManaging, Sendable {
    public init(
        service: String,
        accessGroup: String? = nil,
        defaultSynchronizable: Bool = false,
        maximumValueSizeInBytes: Int = SecureStorageValidation.maximumValueSizeInBytes
    ) {}

    public func data(for key: SecureStorageKey) async throws -> Data? {
        throw SecureStorageError.unsupportedPlatform
    }

    public func record(for key: SecureStorageKey) async throws -> SecureStorageRecord? {
        throw SecureStorageError.unsupportedPlatform
    }

    public func save(_ data: Data, for key: SecureStorageKey, options: SecureStorageSaveOptions = .default) async throws {
        throw SecureStorageError.unsupportedPlatform
    }

    public func removeValue(for key: SecureStorageKey) async throws {
        throw SecureStorageError.unsupportedPlatform
    }

    public func removeAll() async throws {
        throw SecureStorageError.unsupportedPlatform
    }

    public func contains(_ key: SecureStorageKey) async throws -> Bool {
        throw SecureStorageError.unsupportedPlatform
    }

    public func keys() async throws -> [SecureStorageKey] {
        throw SecureStorageError.unsupportedPlatform
    }
}

#endif
