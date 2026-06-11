import Foundation

/// Product-neutral secure storage contract.
///
/// Implementations may use Keychain, an encrypted database, an in-memory store,
/// or a test double. The contract is intentionally async so callers can use the
/// same API with actors, background queues, or platform APIs that may suspend.
public protocol SecureStorageManaging: Sendable {
    func data(for key: SecureStorageKey) async throws -> Data?
    func record(for key: SecureStorageKey) async throws -> SecureStorageRecord?
    func save(_ data: Data, for key: SecureStorageKey, options: SecureStorageSaveOptions) async throws
    func removeValue(for key: SecureStorageKey) async throws
    func removeAll() async throws
    func contains(_ key: SecureStorageKey) async throws -> Bool
    func keys() async throws -> [SecureStorageKey]
}

public extension SecureStorageManaging {
    func record(for key: SecureStorageKey) async throws -> SecureStorageRecord? {
        guard let data = try await data(for: key) else {
            return nil
        }
        return SecureStorageRecord(key: key, data: data)
    }

    func save(_ data: Data, for key: SecureStorageKey) async throws {
        try await save(data, for: key, options: .default)
    }

    func contains(_ key: SecureStorageKey) async throws -> Bool {
        try await data(for: key) != nil
    }

    func value<Value: Decodable & Sendable>(
        for key: SecureStorageKey,
        as type: Value.Type = Value.self,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> Value? {
        guard let data = try await data(for: key) else {
            return nil
        }

        do {
            return try decoder.decode(Value.self, from: data)
        } catch {
            throw SecureStorageError.decodingFailed
        }
    }

    func save<Value: Encodable & Sendable>(
        _ value: Value,
        for key: SecureStorageKey,
        options: SecureStorageSaveOptions = .default,
        encoder: JSONEncoder = JSONEncoder()
    ) async throws {
        do {
            let data = try encoder.encode(value)
            try await save(data, for: key, options: options)
        } catch let error as SecureStorageError {
            throw error
        } catch {
            throw SecureStorageError.encodingFailed
        }
    }
}
