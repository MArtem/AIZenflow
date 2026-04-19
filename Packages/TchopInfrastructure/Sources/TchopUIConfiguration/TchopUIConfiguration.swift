import Foundation

/// Root snapshot describing server-driven UI configuration for the app shell.
public struct UIConfigurationSnapshot: Codable, Equatable, Sendable {
    public let shell: ShellUIConfiguration

    /// Creates a new UIConfigurationSnapshot instance.
    public init(shell: ShellUIConfiguration) {
        self.shell = shell
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

/// Reusable manager that serves current cached configuration and refreshes from a remote source.
public actor UIConfigurationManager: UIConfigurationManaging {
    private let remoteProvider: any UIConfigurationRemoteProviding
    private let store: (any UIConfigurationSnapshotStoring)?
    private let fallbackSnapshot: UIConfigurationSnapshot
    private var currentSnapshot: UIConfigurationSnapshot

    /// Creates a new UIConfigurationManager instance.
    public init(
        remoteProvider: any UIConfigurationRemoteProviding,
        store: (any UIConfigurationSnapshotStoring)? = nil,
        fallbackSnapshot: UIConfigurationSnapshot = UIConfigurationSnapshot(
            shell: ShellUIConfiguration(showsFloatingActionButton: true)
        )
    ) {
        self.remoteProvider = remoteProvider
        self.store = store
        self.fallbackSnapshot = fallbackSnapshot
        self.currentSnapshot = (try? store?.load()) ?? fallbackSnapshot
    }

    /// Returns configuration.
    public func currentConfiguration() async -> UIConfigurationSnapshot {
        currentSnapshot
    }

    /// Handles refresh configuration.
    public func refreshConfiguration() async throws -> UIConfigurationSnapshot {
        let snapshot = try await remoteProvider.fetchConfiguration()
        currentSnapshot = snapshot
        try store?.save(snapshot)
        return snapshot
    }

    /// Fetches configuration.
    public func fetchConfiguration() async throws -> UIConfigurationSnapshot {
        try await refreshConfiguration()
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
