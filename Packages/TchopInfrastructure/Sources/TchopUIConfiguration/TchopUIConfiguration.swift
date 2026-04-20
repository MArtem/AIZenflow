import Foundation

/// Root snapshot describing server-driven UI configuration for the app shell.
public struct UIConfigurationSnapshot: Codable, Equatable, Sendable {
    public static let supportedSchemaVersion = 1

    public let metadata: UIConfigurationSnapshotMetadata
    public let shell: ShellUIConfiguration

    /// Creates a new UIConfigurationSnapshot instance.
    public init(
        metadata: UIConfigurationSnapshotMetadata = UIConfigurationSnapshotMetadata(
            schemaVersion: UIConfigurationSnapshot.supportedSchemaVersion,
            fetchedAt: .distantPast,
            expirationDate: nil
        ),
        shell: ShellUIConfiguration
    ) {
        self.metadata = metadata
        self.shell = shell
    }
}

/// Metadata describing the freshness and schema of a UI configuration snapshot.
public struct UIConfigurationSnapshotMetadata: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let fetchedAt: Date
    public let expirationDate: Date?

    /// Creates a new UIConfigurationSnapshotMetadata instance.
    public init(
        schemaVersion: Int,
        fetchedAt: Date,
        expirationDate: Date?
    ) {
        self.schemaVersion = schemaVersion
        self.fetchedAt = fetchedAt
        self.expirationDate = expirationDate
    }
}

/// Shell-scoped UI toggles that can be modified by remote configuration.
public struct ShellUIConfiguration: Codable, Equatable, Sendable {
    public let showsFloatingActionButton: Bool

    /// Creates a new ShellUIConfiguration instance.
    public init(showsFloatingActionButton: Bool) {
        self.showsFloatingActionButton = showsFloatingActionButton
    }
}

/// Contract for a remote source that fetches UI configuration from backend.
public protocol UIConfigurationRemoteProviding: Sendable {
    /// Fetches configuration.
    func fetchConfiguration() async throws -> UIConfigurationSnapshot
}

/// App-facing contract that can serve the active UI configuration snapshot.
public protocol UIConfigurationManaging: Sendable {
    /// Returns configuration.
    func currentConfiguration() async -> UIConfigurationSnapshot
    /// Returns whether the current configuration should be considered stale.
    func isCurrentConfigurationStale() async -> Bool
    /// Handles refresh configuration.
    func refreshConfiguration() async throws -> UIConfigurationSnapshot
    /// Fetches configuration.
    func fetchConfiguration() async throws -> UIConfigurationSnapshot
}

public extension UIConfigurationManaging {
    /// Fetches configuration.
    func fetchConfiguration() async throws -> UIConfigurationSnapshot {
        try await refreshConfiguration()
    }
}

/// Describes when a cached UI configuration snapshot should be considered stale.
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

/// Persists and restores the last known UI configuration snapshot.
public protocol UIConfigurationSnapshotStoring: Sendable {
    /// Saves this operation.
    func save(_ snapshot: UIConfigurationSnapshot) throws
    /// Loads this operation.
    func load() throws -> UIConfigurationSnapshot?
    /// Clears this operation.
    func clear() throws
}

/// Errors emitted by the default UI configuration snapshot store.
public enum UIConfigurationSnapshotStoreError: Error, Equatable {
    case unavailableUserDefaults(suiteName: String)
}

/// Errors emitted by the reusable UI configuration manager.
public enum UIConfigurationManagerError: Error, Equatable {
    case unsupportedSchemaVersion(actual: Int, supported: Int)
}

/// UserDefaults-backed UI configuration snapshot storage.
public final class UserDefaultsUIConfigurationSnapshotStore:
    @unchecked Sendable,
    UIConfigurationSnapshotStoring
{
    private let userDefaults: UserDefaults
    private let storageKey: String

    /// Creates a new UserDefaultsUIConfigurationSnapshotStore instance.
    public init(
        userDefaults: UserDefaults,
        storageKey: String = "ui-configuration.snapshot"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    /// Creates a new UserDefaultsUIConfigurationSnapshotStore instance.
    public convenience init(
        suiteName: String,
        storageKey: String = "ui-configuration.snapshot"
    ) throws {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw UIConfigurationSnapshotStoreError.unavailableUserDefaults(suiteName: suiteName)
        }

        self.init(userDefaults: userDefaults, storageKey: storageKey)
    }

    /// Saves this operation.
    public func save(_ snapshot: UIConfigurationSnapshot) throws {
        let data = try JSONEncoder().encode(snapshot)
        userDefaults.set(data, forKey: storageKey)
    }

    /// Loads this operation.
    public func load() throws -> UIConfigurationSnapshot? {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return nil
        }

        return try JSONDecoder().decode(UIConfigurationSnapshot.self, from: data)
    }

    /// Clears this operation.
    public func clear() throws {
        userDefaults.removeObject(forKey: storageKey)
    }
}

/// In-memory UI configuration snapshot storage for previews, tests, and ephemeral hosts.
public final class InMemoryUIConfigurationSnapshotStore:
    @unchecked Sendable,
    UIConfigurationSnapshotStoring
{
    private var snapshot: UIConfigurationSnapshot?

    /// Creates a new InMemoryUIConfigurationSnapshotStore instance.
    public init(snapshot: UIConfigurationSnapshot? = nil) {
        self.snapshot = snapshot
    }

    /// Saves this operation.
    public func save(_ snapshot: UIConfigurationSnapshot) throws {
        self.snapshot = snapshot
    }

    /// Loads this operation.
    public func load() throws -> UIConfigurationSnapshot? {
        snapshot
    }

    /// Clears this operation.
    public func clear() throws {
        snapshot = nil
    }
}

/// Reusable manager that serves current cached configuration and refreshes from a remote source.
public actor UIConfigurationManager: UIConfigurationManaging {
    private let remoteProvider: any UIConfigurationRemoteProviding
    private let store: (any UIConfigurationSnapshotStoring)?
    private let fallbackSnapshot: UIConfigurationSnapshot
    private let stalenessPolicy: UIConfigurationStalenessPolicy
    private let refreshThrottling: UIConfigurationRefreshThrottling
    private let dateProvider: @Sendable () -> Date
    private var currentSnapshot: UIConfigurationSnapshot

    /// Creates a new UIConfigurationManager instance.
    public init(
        remoteProvider: any UIConfigurationRemoteProviding,
        store: (any UIConfigurationSnapshotStoring)? = nil,
        stalenessPolicy: UIConfigurationStalenessPolicy = .never,
        refreshThrottling: UIConfigurationRefreshThrottling = .none,
        dateProvider: @escaping @Sendable () -> Date = { Date() },
        fallbackSnapshot: UIConfigurationSnapshot = UIConfigurationSnapshot(
            shell: ShellUIConfiguration(showsFloatingActionButton: true)
        )
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

    /// Returns configuration.
    public func currentConfiguration() async -> UIConfigurationSnapshot {
        currentSnapshot
    }

    /// Returns whether the current configuration should be considered stale.
    public func isCurrentConfigurationStale() async -> Bool {
        Self.isSnapshotStale(
            currentSnapshot,
            policy: stalenessPolicy,
            now: dateProvider()
        )
    }

    /// Handles refresh configuration.
    public func refreshConfiguration() async throws -> UIConfigurationSnapshot {
        let now = dateProvider()
        if shouldUseCurrentSnapshot(for: now) {
            return currentSnapshot
        }

        let snapshot = try await remoteProvider.fetchConfiguration()
        let sanitizedSnapshot = try Self.validatedRemoteSnapshot(snapshot)
        currentSnapshot = sanitizedSnapshot
        try store?.save(sanitizedSnapshot)
        return sanitizedSnapshot
    }

    /// Fetches configuration.
    public func fetchConfiguration() async throws -> UIConfigurationSnapshot {
        try await refreshConfiguration()
    }

    /// Returns whether refresh can safely reuse the current snapshot.
    private func shouldUseCurrentSnapshot(for now: Date) -> Bool {
        guard !Self.isSnapshotStale(currentSnapshot, policy: stalenessPolicy, now: now) else {
            return false
        }

        switch refreshThrottling {
        case .none:
            return false
        case let .minimumInterval(interval):
            return now.timeIntervalSince(currentSnapshot.metadata.fetchedAt) < interval
        }
    }

    /// Returns a snapshot that can safely be used as the active cached state.
    private static func sanitizedSnapshot(
        _ snapshot: UIConfigurationSnapshot?,
        fallbackSnapshot: UIConfigurationSnapshot
    ) -> UIConfigurationSnapshot {
        guard
            let snapshot,
            snapshot.metadata.schemaVersion == UIConfigurationSnapshot.supportedSchemaVersion
        else {
            return fallbackSnapshot
        }

        return snapshot
    }

    /// Validates a newly fetched remote snapshot before storing and exposing it.
    private static func validatedRemoteSnapshot(
        _ snapshot: UIConfigurationSnapshot
    ) throws -> UIConfigurationSnapshot {
        guard snapshot.metadata.schemaVersion == UIConfigurationSnapshot.supportedSchemaVersion else {
            throw UIConfigurationManagerError.unsupportedSchemaVersion(
                actual: snapshot.metadata.schemaVersion,
                supported: UIConfigurationSnapshot.supportedSchemaVersion
            )
        }

        return snapshot
    }

    /// Returns whether the provided snapshot is stale under the supplied policy.
    private static func isSnapshotStale(
        _ snapshot: UIConfigurationSnapshot,
        policy: UIConfigurationStalenessPolicy,
        now: Date
    ) -> Bool {
        switch policy {
        case .never:
            return false
        case let .after(interval):
            return now.timeIntervalSince(snapshot.metadata.fetchedAt) >= interval
        case .expirationDate:
            guard let expirationDate = snapshot.metadata.expirationDate else {
                return false
            }

            return now >= expirationDate
        }
    }
}

/// Mock remote source used until a real backend contract exists.
public struct MockUIConfigurationRemoteProvider: UIConfigurationRemoteProviding {
    private let response: UIConfigurationSnapshot
    private let delayNanoseconds: UInt64

    /// Creates a new MockUIConfigurationRemoteProvider instance.
    public init(
        response: UIConfigurationSnapshot = UIConfigurationSnapshot(
            shell: ShellUIConfiguration(showsFloatingActionButton: true)
        ),
        delayNanoseconds: UInt64 = 120_000_000
    ) {
        self.response = response
        self.delayNanoseconds = delayNanoseconds
    }

    /// Fetches configuration.
    public func fetchConfiguration() async throws -> UIConfigurationSnapshot {
        try await Task.sleep(nanoseconds: delayNanoseconds)
        try Task.checkCancellation()
        return response
    }
}
