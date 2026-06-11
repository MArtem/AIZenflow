import Foundation
import Observation

/// Defines stack mutation policy for navigation transitions.
public enum NavigationTransitionPolicy: String, Codable, Equatable, Sendable {
    case push
    case replace
    case popToRoot
}

/// Typed events emitted by navigation restore and deep-link flows.
///
/// Events are immutable diagnostic values and can cross concurrency boundaries. Reporter implementations may still
/// choose main-actor isolation when their storage or analytics integration requires it.
public enum NavigationEvent: Equatable, Sendable {
    case deepLinkHandled(url: String, destination: String, policy: NavigationTransitionPolicy)
    case deepLinkRejected(url: String, reason: String)
    case deepLinkFallback(url: String, reason: String)
    case snapshotRestoreStarted(userID: String, sourceVersion: Int)
    case snapshotRestoreCompleted(
        userID: String,
        appliedVersion: Int,
        wasSanitized: Bool,
        wasMigrated: Bool
    )
    case snapshotRestoreSkipped(userID: String, reason: String)
    case snapshotRestoreFailed(userID: String, reason: String)
}

/// Contract used to report navigation events for diagnostics and observability.
@MainActor
public protocol NavigationEventReporting: AnyObject {
    /// Reports this operation.
    func report(_ event: NavigationEvent)
}

/// Default no-op navigation event reporter.
@MainActor
public final class NavigationNoopEventReporter: NavigationEventReporting {
    /// Creates a new NavigationNoopEventReporter instance.
    public init() {}

    /// Reports this operation.
    public func report(_ event: NavigationEvent) {}
}

/// In-memory navigation reporter primarily used by tests.
@MainActor
public final class NavigationMemoryEventReporter: NavigationEventReporting {
    public private(set) var events: [NavigationEvent] = []

    /// Creates a new NavigationMemoryEventReporter instance.
    public init() {}

    /// Reports this operation.
    public func report(_ event: NavigationEvent) {
        events.append(event)
    }
}

/// Generic router that stores a typed navigation path for a single stack.
@MainActor
@Observable
public final class TabRouter<Route: Hashable> {
    /// Current navigation path.
    public var path: [Route] {
        didSet {
            onPathChange?()
        }
    }

    @ObservationIgnored
    public var onPathChange: (@MainActor () -> Void)?

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

    /// Saves snapshot.
    public func saveSnapshot<Snapshot: Codable>(_ snapshot: Snapshot, for userID: String) {
        guard let encodedSnapshot = try? encoder.encode(snapshot) else {
            assertionFailure("Failed to encode navigation snapshot.")
            return
        }

        userDefaults.set(encodedSnapshot, forKey: key(for: userID))
    }

    /// Restores snapshot.
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

    /// Clears snapshot.
    public func clearSnapshot(for userID: String) {
        userDefaults.removeObject(forKey: key(for: userID))
    }

    /// Handles key.
    private func key(for userID: String) -> String {
        Constants.snapshotKeyPrefix + userID
    }
}
