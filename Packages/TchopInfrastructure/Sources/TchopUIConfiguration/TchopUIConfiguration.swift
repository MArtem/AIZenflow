import Foundation

/// Root snapshot describing server-driven UI configuration for the app shell.
public struct UIConfigurationSnapshot: Codable, Equatable, Sendable {
    public let shell: ShellUIConfiguration

    public init(shell: ShellUIConfiguration) {
        self.shell = shell
    }
}

/// Shell-scoped UI toggles that can be modified by remote configuration.
public struct ShellUIConfiguration: Codable, Equatable, Sendable {
    public let showsFloatingActionButton: Bool

    public init(showsFloatingActionButton: Bool) {
        self.showsFloatingActionButton = showsFloatingActionButton
    }
}

/// Contract for a remote source that fetches UI configuration from backend.
public protocol UIConfigurationRemoteProviding: Sendable {
    func fetchConfiguration() async throws -> UIConfigurationSnapshot
}

/// App-facing contract that can serve the active UI configuration snapshot.
public protocol UIConfigurationManaging: Sendable {
    func currentConfiguration() async -> UIConfigurationSnapshot
    func refreshConfiguration() async throws -> UIConfigurationSnapshot
    func fetchConfiguration() async throws -> UIConfigurationSnapshot
}

public extension UIConfigurationManaging {
    func fetchConfiguration() async throws -> UIConfigurationSnapshot {
        try await refreshConfiguration()
    }
}

/// Persists and restores the last known UI configuration snapshot.
public protocol UIConfigurationSnapshotStoring: Sendable {
    func save(_ snapshot: UIConfigurationSnapshot) throws
    func load() throws -> UIConfigurationSnapshot?
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

    public init(
        userDefaults: UserDefaults,
        storageKey: String = "ui-configuration.snapshot"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public convenience init(
        suiteName: String,
        storageKey: String = "ui-configuration.snapshot"
    ) throws {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw UIConfigurationSnapshotStoreError.unavailableUserDefaults(suiteName: suiteName)
        }

        self.init(userDefaults: userDefaults, storageKey: storageKey)
    }

    public func save(_ snapshot: UIConfigurationSnapshot) throws {
        let data = try JSONEncoder().encode(snapshot)
        userDefaults.set(data, forKey: storageKey)
    }

    public func load() throws -> UIConfigurationSnapshot? {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return nil
        }

        return try JSONDecoder().decode(UIConfigurationSnapshot.self, from: data)
    }

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

    public func currentConfiguration() async -> UIConfigurationSnapshot {
        currentSnapshot
    }

    public func refreshConfiguration() async throws -> UIConfigurationSnapshot {
        let snapshot = try await remoteProvider.fetchConfiguration()
        currentSnapshot = snapshot
        try store?.save(snapshot)
        return snapshot
    }

    public func fetchConfiguration() async throws -> UIConfigurationSnapshot {
        try await refreshConfiguration()
    }
}

/// Mock remote source used until a real backend contract exists.
public struct MockUIConfigurationRemoteProvider: UIConfigurationRemoteProviding {
    private let response: UIConfigurationSnapshot
    private let delayNanoseconds: UInt64

    public init(
        response: UIConfigurationSnapshot = UIConfigurationSnapshot(
            shell: ShellUIConfiguration(showsFloatingActionButton: true)
        ),
        delayNanoseconds: UInt64 = 120_000_000
    ) {
        self.response = response
        self.delayNanoseconds = delayNanoseconds
    }

    public func fetchConfiguration() async throws -> UIConfigurationSnapshot {
        try await Task.sleep(nanoseconds: delayNanoseconds)
        try Task.checkCancellation()
        return response
    }
}
