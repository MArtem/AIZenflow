import Foundation

/// Metadata describing the freshness and schema of a remote configuration snapshot.
public struct UIConfigurationSnapshotMetadata: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let fetchedAt: Date
    public let expirationDate: Date?

    public init(schemaVersion: Int, fetchedAt: Date, expirationDate: Date?) {
        self.schemaVersion = schemaVersion
        self.fetchedAt = fetchedAt
        self.expirationDate = expirationDate
    }
}

/// Generic remote configuration snapshot.
///
/// Boundary rule:
/// The reusable package owns schema/freshness mechanics. Apps own the concrete payload type and feature policy.
public struct UIConfigurationSnapshot<Payload>: Codable, Equatable, Sendable
where Payload: Codable & Equatable & Sendable {
    public static var supportedSchemaVersion: Int { 1 }

    public let metadata: UIConfigurationSnapshotMetadata
    public let payload: Payload

    public init(
        metadata: UIConfigurationSnapshotMetadata = UIConfigurationSnapshotMetadata(
            schemaVersion: UIConfigurationSnapshot.supportedSchemaVersion,
            fetchedAt: .distantPast,
            expirationDate: nil
        ),
        payload: Payload
    ) {
        self.metadata = metadata
        self.payload = payload
    }
}

/// Contract for a remote source that fetches one concrete configuration payload.
public protocol UIConfigurationRemoteProviding<Payload>: Sendable {
    associatedtype Payload: Codable & Equatable & Sendable

    func fetchConfiguration() async throws -> UIConfigurationSnapshot<Payload>
}

/// App-facing contract that can serve one concrete configuration payload.
public protocol UIConfigurationManaging<Payload>: Sendable {
    associatedtype Payload: Codable & Equatable & Sendable

    func currentConfiguration() async -> UIConfigurationSnapshot<Payload>
    func isCurrentConfigurationStale() async -> Bool
    func refreshConfiguration() async throws -> UIConfigurationSnapshot<Payload>
    func fetchConfiguration() async throws -> UIConfigurationSnapshot<Payload>
}

public extension UIConfigurationManaging {
    func fetchConfiguration() async throws -> UIConfigurationSnapshot<Payload> {
        try await refreshConfiguration()
    }
}

/// Describes when a cached configuration snapshot should be considered stale.
public enum UIConfigurationStalenessPolicy: Equatable, Sendable {
    case never
    case after(TimeInterval)
    case expirationDate
}

/// Describes when refresh requests should reuse the current snapshot instead of hitting remote.
public enum UIConfigurationRefreshThrottling: Equatable, Sendable {
    case none
    case minimumInterval(TimeInterval)
}

/// Persists and restores one concrete configuration snapshot.
public protocol UIConfigurationSnapshotStoring<Payload>: Sendable {
    associatedtype Payload: Codable & Equatable & Sendable

    func save(_ snapshot: UIConfigurationSnapshot<Payload>) throws
    func load() throws -> UIConfigurationSnapshot<Payload>?
    func clear() throws
}

/// Errors emitted by the default configuration snapshot store.
public enum UIConfigurationSnapshotStoreError: Error, Equatable, Sendable {
    case unavailableUserDefaults(suiteName: String)
}

/// Errors emitted by the reusable configuration manager.
public enum UIConfigurationManagerError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(actual: Int, supported: Int)
}

/// UserDefaults-backed generic configuration snapshot storage.
///
/// Thread safety:
/// `UserDefaults` supports concurrent access for individual operations. This class stores immutable
/// key/configuration state only; payload mutation is not retained in the store instance.
public final class UserDefaultsUIConfigurationSnapshotStore<Payload>:
    @unchecked Sendable,
    UIConfigurationSnapshotStoring
where Payload: Codable & Equatable & Sendable {
    private let userDefaults: UserDefaults
    private let storageKey: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(userDefaults: UserDefaults, storageKey: String = "ui-configuration.snapshot") {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public convenience init(suiteName: String, storageKey: String = "ui-configuration.snapshot") throws {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw UIConfigurationSnapshotStoreError.unavailableUserDefaults(suiteName: suiteName)
        }
        self.init(userDefaults: userDefaults, storageKey: storageKey)
    }

    public func save(_ snapshot: UIConfigurationSnapshot<Payload>) throws {
        let data = try encoder.encode(snapshot)
        userDefaults.set(data, forKey: storageKey)
    }

    public func load() throws -> UIConfigurationSnapshot<Payload>? {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return nil
        }
        return try decoder.decode(UIConfigurationSnapshot<Payload>.self, from: data)
    }

    public func clear() throws {
        userDefaults.removeObject(forKey: storageKey)
    }
}

/// In-memory configuration snapshot storage for previews, tests, and ephemeral hosts.
///
/// Thread safety:
/// A small `NSLock` protects the mutable snapshot so the store can satisfy the synchronous storage
/// protocol without forcing all store implementations to become actors.
public final class InMemoryUIConfigurationSnapshotStore<Payload>:
    @unchecked Sendable,
    UIConfigurationSnapshotStoring
where Payload: Codable & Equatable & Sendable {
    private let lock = NSLock()
    private var snapshot: UIConfigurationSnapshot<Payload>?

    public init(snapshot: UIConfigurationSnapshot<Payload>? = nil) {
        self.snapshot = snapshot
    }

    public func save(_ snapshot: UIConfigurationSnapshot<Payload>) throws {
        lock.lock()
        self.snapshot = snapshot
        lock.unlock()
    }

    public func load() throws -> UIConfigurationSnapshot<Payload>? {
        lock.lock()
        defer { lock.unlock() }
        return snapshot
    }

    public func clear() throws {
        lock.lock()
        snapshot = nil
        lock.unlock()
    }
}

/// Reusable manager that serves a cached configuration and refreshes from a remote source.
public actor UIConfigurationManager<Payload>: UIConfigurationManaging
where Payload: Codable & Equatable & Sendable {
    private let remoteProvider: any UIConfigurationRemoteProviding<Payload>
    private let store: (any UIConfigurationSnapshotStoring<Payload>)?
    private let fallbackSnapshot: UIConfigurationSnapshot<Payload>
    private let stalenessPolicy: UIConfigurationStalenessPolicy
    private let refreshThrottling: UIConfigurationRefreshThrottling
    private let dateProvider: @Sendable () -> Date
    private var currentSnapshot: UIConfigurationSnapshot<Payload>
    private var lastRefreshAttempt: Date?

    public init(
        remoteProvider: any UIConfigurationRemoteProviding<Payload>,
        store: (any UIConfigurationSnapshotStoring<Payload>)? = nil,
        stalenessPolicy: UIConfigurationStalenessPolicy = .never,
        refreshThrottling: UIConfigurationRefreshThrottling = .none,
        dateProvider: @escaping @Sendable () -> Date = { Date() },
        fallbackSnapshot: UIConfigurationSnapshot<Payload>
    ) {
        self.remoteProvider = remoteProvider
        self.store = store
        self.stalenessPolicy = stalenessPolicy
        self.refreshThrottling = refreshThrottling
        self.dateProvider = dateProvider
        self.fallbackSnapshot = fallbackSnapshot
        self.currentSnapshot = Self.sanitizedSnapshot(
            try? store?.load(),
            fallbackSnapshot: fallbackSnapshot
        )
    }

    public func currentConfiguration() async -> UIConfigurationSnapshot<Payload> {
        currentSnapshot
    }

    public func isCurrentConfigurationStale() async -> Bool {
        isSnapshotStale(currentSnapshot, now: dateProvider())
    }

    public func refreshConfiguration() async throws -> UIConfigurationSnapshot<Payload> {
        let now = dateProvider()
        if shouldThrottleRefresh(now: now) {
            return currentSnapshot
        }

        lastRefreshAttempt = now
        let snapshot = try await remoteProvider.fetchConfiguration()
        let sanitized = try Self.validatedSnapshot(snapshot)
        currentSnapshot = sanitized
        try store?.save(sanitized)
        return sanitized
    }

    private func shouldThrottleRefresh(now: Date) -> Bool {
        guard let lastRefreshAttempt else { return false }
        switch refreshThrottling {
        case .none:
            return false
        case .minimumInterval(let interval):
            return now.timeIntervalSince(lastRefreshAttempt) < interval
        }
    }

    private func isSnapshotStale(_ snapshot: UIConfigurationSnapshot<Payload>, now: Date) -> Bool {
        switch stalenessPolicy {
        case .never:
            return false
        case .after(let interval):
            return now.timeIntervalSince(snapshot.metadata.fetchedAt) >= interval
        case .expirationDate:
            guard let expirationDate = snapshot.metadata.expirationDate else { return false }
            return now >= expirationDate
        }
    }

    private static func sanitizedSnapshot(
        _ snapshot: UIConfigurationSnapshot<Payload>?,
        fallbackSnapshot: UIConfigurationSnapshot<Payload>
    ) -> UIConfigurationSnapshot<Payload> {
        guard let snapshot else { return fallbackSnapshot }
        guard let validated = try? validatedSnapshot(snapshot) else { return fallbackSnapshot }
        return validated
    }

    private static func validatedSnapshot(
        _ snapshot: UIConfigurationSnapshot<Payload>
    ) throws -> UIConfigurationSnapshot<Payload> {
        guard snapshot.metadata.schemaVersion == UIConfigurationSnapshot<Payload>.supportedSchemaVersion else {
            throw UIConfigurationManagerError.unsupportedSchemaVersion(
                actual: snapshot.metadata.schemaVersion,
                supported: UIConfigurationSnapshot<Payload>.supportedSchemaVersion
            )
        }
        return snapshot
    }
}

/// Static remote provider useful for local configuration and tests.
public struct StaticUIConfigurationProvider<Payload>: UIConfigurationRemoteProviding
where Payload: Codable & Equatable & Sendable {
    private let snapshot: UIConfigurationSnapshot<Payload>
    private let delayNanoseconds: UInt64

    public init(snapshot: UIConfigurationSnapshot<Payload>, delayNanoseconds: UInt64 = 0) {
        self.snapshot = snapshot
        self.delayNanoseconds = delayNanoseconds
    }

    public func fetchConfiguration() async throws -> UIConfigurationSnapshot<Payload> {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        return snapshot
    }
}
