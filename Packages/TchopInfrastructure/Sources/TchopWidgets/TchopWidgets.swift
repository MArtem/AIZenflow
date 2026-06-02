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
/// Thread safety:
/// `UserDefaults` supports concurrent access for individual operations. This class stores no mutable
/// state beyond immutable encoder/decoder/key configuration, so the unchecked sendability is limited to
/// the injected `UserDefaults` runtime guarantee.
public final class UserDefaultsWidgetSnapshotStore<Snapshot>: @unchecked Sendable, WidgetSnapshotStoring
where Snapshot: Codable & Sendable {
    private let userDefaults: UserDefaults
    private let snapshotKey: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// Creates a snapshot store using a concrete `UserDefaults` instance.
    public init(userDefaults: UserDefaults, snapshotKey: String) {
        self.userDefaults = userDefaults
        self.snapshotKey = snapshotKey
    }

    /// Creates a snapshot store using an app-group suite name.
    public convenience init(suiteName: String, snapshotKey: String) throws {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw WidgetSnapshotStoreError.unavailableSharedDefaults(suiteName: suiteName)
        }
        self.init(userDefaults: userDefaults, snapshotKey: snapshotKey)
    }

    /// Saves the latest snapshot value.
    public func save(_ snapshot: Snapshot) throws {
        let data = try encoder.encode(snapshot)
        userDefaults.set(data, forKey: snapshotKey)
    }

    /// Loads the latest snapshot value, returning `nil` when no snapshot exists.
    public func load() throws -> Snapshot? {
        guard let data = userDefaults.data(forKey: snapshotKey) else {
            return nil
        }
        return try decoder.decode(Snapshot.self, from: data)
    }

    /// Clears the stored snapshot.
    public func clear() throws {
        userDefaults.removeObject(forKey: snapshotKey)
    }
}
