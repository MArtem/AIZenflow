import Combine
import Foundation

/// Generic router that stores a typed navigation path for a single stack.
@MainActor
public final class TabRouter<Route: Hashable>: ObservableObject {
    /// Current navigation path.
    @Published public var path: [Route]

    /// Creates a router with an optional initial path.
    public init(path: [Route] = []) {
        self.path = path
    }

    /// Pushes a new route onto the navigation stack.
    public func push(_ route: Route) {
        path.append(route)
    }

    /// Pops the top route when available.
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Clears the navigation stack.
    public func popToRoot() {
        path.removeAll()
    }

    /// Replaces the entire navigation path with a new value.
    public func replacePath(with newPath: [Route]) {
        path = newPath
    }
}

/// Persistence contract for per-user navigation snapshots.
///
/// The contract is generic and can persist any `Codable` snapshot model.
@MainActor
public protocol NavigationStateManaging: AnyObject {
    /// Saves snapshot for the provided user identifier.
    func saveSnapshot<Snapshot: Codable>(_ snapshot: Snapshot, for userID: String)

    /// Restores previously saved snapshot for the provided user identifier.
    func restoreSnapshot<Snapshot: Codable>(for userID: String, as snapshotType: Snapshot.Type) -> Snapshot?

    /// Removes previously saved snapshot for the provided user identifier.
    func clearSnapshot(for userID: String)
}

/// UserDefaults-backed generic snapshot persistence.
@MainActor
public final class NavigationStateManager: NavigationStateManaging {
    private enum Constants {
        static let snapshotKeyPrefix = "navigation_snapshot_"
    }

    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// Creates a new persistence manager.
    public init(
        userDefaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }

    public func saveSnapshot<Snapshot: Codable>(_ snapshot: Snapshot, for userID: String) {
        guard let encodedSnapshot = try? encoder.encode(snapshot) else {
            assertionFailure("Failed to encode navigation snapshot.")
            return
        }

        userDefaults.set(encodedSnapshot, forKey: key(for: userID))
    }

    public func restoreSnapshot<Snapshot: Codable>(
        for userID: String,
        as snapshotType: Snapshot.Type
    ) -> Snapshot? {
        guard let rawSnapshot = userDefaults.data(forKey: key(for: userID)) else {
            return nil
        }

        guard let decodedSnapshot = try? decoder.decode(snapshotType, from: rawSnapshot) else {
            userDefaults.removeObject(forKey: key(for: userID))
            return nil
        }

        return decodedSnapshot
    }

    public func clearSnapshot(for userID: String) {
        userDefaults.removeObject(forKey: key(for: userID))
    }

    private func key(for userID: String) -> String {
        Constants.snapshotKeyPrefix + userID
    }
}
