import Foundation

/// Stable identifiers shared between the app and widget extension.
public enum FeedHeadlineWidgetConstants {
    public static let widgetKind = "FeedHeadlineWidget"
    public static let snapshotKey = "widgets.feed.headline.snapshot"
}

/// Snapshot rendered by the feed headline widget.
public struct FeedHeadlineWidgetSnapshot: Codable, Equatable, Sendable {
    public let headline: String
    public let updatedAt: Date

    /// Creates a new FeedHeadlineWidgetSnapshot instance.
    public init(headline: String, updatedAt: Date = Date()) {
        self.headline = headline
        self.updatedAt = updatedAt
    }
}

/// Shared persistence contract used by the app and widget extension.
public protocol FeedHeadlineWidgetSnapshotManaging: Sendable {
    /// Saves this operation.
    func save(_ snapshot: FeedHeadlineWidgetSnapshot) throws
    /// Loads this operation.
    func load() throws -> FeedHeadlineWidgetSnapshot?
    /// Clears this operation.
    func clear() throws
}

/// Errors produced by the shared widget snapshot manager.
public enum FeedHeadlineWidgetSnapshotStoreError: Error {
    case unavailableSharedDefaults(suiteName: String)
}

/// UserDefaults-backed manager that persists widget snapshots in app-group storage.
public final class UserDefaultsFeedHeadlineWidgetSnapshotManager:
    @unchecked Sendable,
    FeedHeadlineWidgetSnapshotManaging
{
    private let userDefaults: UserDefaults
    private let snapshotKey: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// Creates a new UserDefaultsFeedHeadlineWidgetSnapshotManager instance.
    public init(
        userDefaults: UserDefaults,
        snapshotKey: String = FeedHeadlineWidgetConstants.snapshotKey
    ) {
        self.userDefaults = userDefaults
        self.snapshotKey = snapshotKey
    }

    /// Creates a new UserDefaultsFeedHeadlineWidgetSnapshotManager instance.
    public convenience init(
        suiteName: String,
        snapshotKey: String = FeedHeadlineWidgetConstants.snapshotKey
    ) throws {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw FeedHeadlineWidgetSnapshotStoreError.unavailableSharedDefaults(suiteName: suiteName)
        }

        self.init(userDefaults: userDefaults, snapshotKey: snapshotKey)
    }

    /// Saves this operation.
    public func save(_ snapshot: FeedHeadlineWidgetSnapshot) throws {
        let data = try encoder.encode(snapshot)
        userDefaults.set(data, forKey: snapshotKey)
    }

    /// Loads this operation.
    public func load() throws -> FeedHeadlineWidgetSnapshot? {
        guard let data = userDefaults.data(forKey: snapshotKey) else {
            return nil
        }

        return try decoder.decode(FeedHeadlineWidgetSnapshot.self, from: data)
    }

    /// Clears this operation.
    public func clear() throws {
        userDefaults.removeObject(forKey: snapshotKey)
    }
}
