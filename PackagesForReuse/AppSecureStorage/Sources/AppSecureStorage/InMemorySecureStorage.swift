import Foundation

/// Actor-backed in-memory secure storage for tests, previews, and ephemeral flows.
///
/// This implementation does not provide real security. It exists so production
/// code can be tested without touching Keychain or platform state.
public actor InMemorySecureStorage: SecureStorageManaging {
    private var storage: [SecureStorageKey: Data]
    private let maximumValueSizeInBytes: Int

    public init(
        initialValues: [SecureStorageKey: Data] = [:],
        maximumValueSizeInBytes: Int = SecureStorageValidation.maximumValueSizeInBytes
    ) {
        self.storage = initialValues
        self.maximumValueSizeInBytes = maximumValueSizeInBytes
    }

    public func data(for key: SecureStorageKey) async throws -> Data? {
        try SecureStorageValidation.validateKey(key)
        return storage[key]
    }

    public func record(for key: SecureStorageKey) async throws -> SecureStorageRecord? {
        try SecureStorageValidation.validateKey(key)
        guard let data = storage[key] else {
            return nil
        }
        return SecureStorageRecord(key: key, data: data)
    }

    public func save(_ data: Data, for key: SecureStorageKey, options: SecureStorageSaveOptions = .default) async throws {
        try SecureStorageValidation.validateKey(key)
        try SecureStorageValidation.validateValueSize(data, maximumBytes: maximumValueSizeInBytes)
        storage[key] = data
    }

    public func removeValue(for key: SecureStorageKey) async throws {
        try SecureStorageValidation.validateKey(key)
        storage.removeValue(forKey: key)
    }

    public func removeAll() async throws {
        storage.removeAll()
    }

    public func contains(_ key: SecureStorageKey) async throws -> Bool {
        try SecureStorageValidation.validateKey(key)
        return storage[key] != nil
    }

    public func keys() async throws -> [SecureStorageKey] {
        storage.keys.sorted { $0.rawValue < $1.rawValue }
    }
}
