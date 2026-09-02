import Foundation

/// Generic persistence contract for small Codable widget snapshots shared between an app and widget extension.
///
/// Ownership:
/// The package owns storage mechanics only. The app or feature target owns concrete snapshot payloads,
/// widget kinds, keys, and rendering policy.
public protocol WidgetSnapshotStoring<Snapshot>: Sendable {
    associatedtype Snapshot: Codable & Sendable

    /// Saves the latest snapshot value.
    func save(_ snapshot: Snapshot) throws

    /// Loads the latest snapshot value, returning `nil` when no snapshot exists.
    func load() throws -> Snapshot?

    /// Clears the stored snapshot.
    func clear() throws
}

/// Errors produced by reusable widget snapshot stores.
public enum WidgetSnapshotStoreError: Error, Equatable, Sendable {
    case unavailableSharedDefaults(suiteName: String)
}

/// UserDefaults-backed generic widget snapshot store for app-group sharing.
///
/// Sendability:
/// The store retains only a sendable defaults location and key. Each operation resolves the
/// corresponding `UserDefaults` instance locally, so no imported reference crosses a boundary.
public struct UserDefaultsWidgetSnapshotStore<Snapshot>: WidgetSnapshotStoring
where Snapshot: Codable & Sendable {
    private enum DefaultsLocation: Sendable {
        case standard
        case suite(String)
    }

    private let location: DefaultsLocation
    private let snapshotKey: String

    /// Creates a snapshot store using standard defaults.
    public init(snapshotKey: String) {
        self.location = .standard
        self.snapshotKey = snapshotKey
    }

    /// Creates a snapshot store using an app-group suite name.
    public init(suiteName: String, snapshotKey: String) throws {
        guard UserDefaults(suiteName: suiteName) != nil else {
            throw WidgetSnapshotStoreError.unavailableSharedDefaults(suiteName: suiteName)
        }
        self.location = .suite(suiteName)
        self.snapshotKey = snapshotKey
    }

    /// Saves the latest snapshot value.
    public func save(_ snapshot: Snapshot) throws {
        let data = try JSONEncoder().encode(snapshot)
        defaults.set(data, forKey: snapshotKey)
    }

    /// Loads the latest snapshot value, returning `nil` when no snapshot exists.
    public func load() throws -> Snapshot? {
        guard let data = defaults.data(forKey: snapshotKey) else {
            return nil
        }
        return try JSONDecoder().decode(Snapshot.self, from: data)
    }

    /// Clears the stored snapshot.
    public func clear() throws {
        defaults.removeObject(forKey: snapshotKey)
    }

    private var defaults: UserDefaults {
        switch location {
        case .standard:
            .standard
        case let .suite(suiteName):
            UserDefaults(suiteName: suiteName) ?? .standard
        }
    }
}
