import Foundation

/// Expiration policy used for cached records.
public enum CacheExpiration: Sendable {
    case never
    case after(TimeInterval)
    case at(Date)

    func resolveDate(from now: Date) -> Date? {
        switch self {
        case .never:
            return nil
        case let .after(interval):
            return now.addingTimeInterval(interval)
        case let .at(date):
            return date
        }
    }
}

/// Generic contract for local cache managers.
public protocol LocalCacheManaging: Sendable {
    func setValue<Value: Codable & Sendable>(
        _ value: Value,
        forKey key: String,
        expiration: CacheExpiration
    ) async throws

    func value<Value: Codable & Sendable>(
        forKey key: String,
        as type: Value.Type
    ) async throws -> Value?

    func removeValue(forKey key: String) async throws

    func clear() async throws
}

/// Errors emitted by local cache managers.
public enum LocalCacheError: Error, Equatable {
    case invalidKey
    case serializationFailed
    case deserializationFailed
}

/// In-memory local cache manager with optional per-entry expiration.
public actor InMemoryLocalCacheManager: LocalCacheManaging {
    private var storage: [String: StoredCacheEntry] = [:]
    private let dateProvider: @Sendable () -> Date

    public init(dateProvider: @escaping @Sendable () -> Date = { Date() }) {
        self.dateProvider = dateProvider
    }

    public func setValue<Value: Codable & Sendable>(
        _ value: Value,
        forKey key: String,
        expiration: CacheExpiration = .never
    ) async throws {
        let normalizedKey = try validateCacheKey(key)
        let data = try encodeCacheValue(value)
        let expirationDate = expiration.resolveDate(from: dateProvider())
        storage[normalizedKey] = StoredCacheEntry(payload: data, expirationDate: expirationDate)
    }

    public func value<Value: Codable & Sendable>(
        forKey key: String,
        as type: Value.Type
    ) async throws -> Value? {
        let normalizedKey = try validateCacheKey(key)
        guard let entry = storage[normalizedKey] else {
            return nil
        }
        guard !entry.isExpired(now: dateProvider()) else {
            storage[normalizedKey] = nil
            return nil
        }
        return try decodeCacheValue(entry.payload, as: type)
    }

    public func removeValue(forKey key: String) async throws {
        let normalizedKey = try validateCacheKey(key)
        storage[normalizedKey] = nil
    }

    public func clear() async throws {
        storage.removeAll(keepingCapacity: false)
    }
}

/// File-backed local cache manager with optional per-entry expiration.
public actor FileLocalCacheManager: LocalCacheManaging {
    private let directoryURL: URL
    private let fileManager: FileManager
    private let dateProvider: @Sendable () -> Date

    public init(
        directoryURL: URL? = nil,
        fileManager: FileManager = .default,
        dateProvider: @escaping @Sendable () -> Date = { Date() }
    ) throws {
        self.fileManager = fileManager
        self.dateProvider = dateProvider
        if let directoryURL {
            self.directoryURL = directoryURL
        } else {
            let baseDirectory = try fileManager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            self.directoryURL = baseDirectory.appendingPathComponent("TchopCache", isDirectory: true)
        }
        try fileManager.createDirectory(at: self.directoryURL, withIntermediateDirectories: true)
    }

    public func setValue<Value: Codable & Sendable>(
        _ value: Value,
        forKey key: String,
        expiration: CacheExpiration = .never
    ) async throws {
        let normalizedKey = try validateCacheKey(key)
        let payload = try encodeCacheValue(value)
        let entry = StoredCacheEntry(
            payload: payload,
            expirationDate: expiration.resolveDate(from: dateProvider())
        )
        let encodedEntry = try encodeCacheValue(entry)
        try encodedEntry.write(to: cacheFileURL(for: normalizedKey), options: .atomic)
    }

    public func value<Value: Codable & Sendable>(
        forKey key: String,
        as type: Value.Type
    ) async throws -> Value? {
        let normalizedKey = try validateCacheKey(key)
        let fileURL = cacheFileURL(for: normalizedKey)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let entryData = try Data(contentsOf: fileURL)
        let entry: StoredCacheEntry = try decodeCacheValue(entryData, as: StoredCacheEntry.self)
        guard !entry.isExpired(now: dateProvider()) else {
            try? fileManager.removeItem(at: fileURL)
            return nil
        }
        return try decodeCacheValue(entry.payload, as: type)
    }

    public func removeValue(forKey key: String) async throws {
        let normalizedKey = try validateCacheKey(key)
        let fileURL = cacheFileURL(for: normalizedKey)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return
        }
        try fileManager.removeItem(at: fileURL)
    }

    public func clear() async throws {
        guard fileManager.fileExists(atPath: directoryURL.path) else {
            return
        }

        let items = try fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        )
        for item in items {
            try fileManager.removeItem(at: item)
        }
    }

    private func cacheFileURL(for key: String) -> URL {
        let encodedKey = Data(key.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
        return directoryURL.appendingPathComponent(encodedKey).appendingPathExtension("cache")
    }
}

private struct StoredCacheEntry: Codable, Sendable {
    let payload: Data
    let expirationDate: Date?

    func isExpired(now: Date) -> Bool {
        guard let expirationDate else {
            return false
        }
        return now >= expirationDate
    }
}

private func validateCacheKey(_ key: String) throws -> String {
    let normalizedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedKey.isEmpty else {
        throw LocalCacheError.invalidKey
    }
    return normalizedKey
}

private func encodeCacheValue<T: Encodable>(_ value: T) throws -> Data {
    do {
        return try JSONEncoder().encode(value)
    } catch {
        throw LocalCacheError.serializationFailed
    }
}

private func decodeCacheValue<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
    do {
        return try JSONDecoder().decode(type, from: data)
    } catch {
        throw LocalCacheError.deserializationFailed
    }
}
