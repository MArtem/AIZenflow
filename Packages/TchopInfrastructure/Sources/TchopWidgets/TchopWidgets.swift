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

    public init(headline: String, updatedAt: Date = Date()) {
        self.headline = headline
        self.updatedAt = updatedAt
    }
}

/// Shared persistence contract used by the app and widget extension.
public protocol FeedHeadlineWidgetSnapshotManaging {
    func save(_ snapshot: FeedHeadlineWidgetSnapshot) throws
    func load() throws -> FeedHeadlineWidgetSnapshot?
    func clear() throws
}

/// Errors produced by the shared widget snapshot manager.
public enum FeedHeadlineWidgetSnapshotStoreError: Error {
    case unavailableSharedDefaults(suiteName: String)
}

/// UserDefaults-backed manager that persists widget snapshots in app-group storage.
public final class UserDefaultsFeedHeadlineWidgetSnapshotManager: FeedHeadlineWidgetSnapshotManaging {
    private let userDefaults: UserDefaults
    private let snapshotKey: String

    public init(
        userDefaults: UserDefaults,
        snapshotKey: String = FeedHeadlineWidgetConstants.snapshotKey
    ) {
        self.userDefaults = userDefaults
        self.snapshotKey = snapshotKey
    }

    public convenience init(
        suiteName: String,
        snapshotKey: String = FeedHeadlineWidgetConstants.snapshotKey
    ) throws {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw FeedHeadlineWidgetSnapshotStoreError.unavailableSharedDefaults(suiteName: suiteName)
        }

        self.init(userDefaults: userDefaults, snapshotKey: snapshotKey)
    }

    public func save(_ snapshot: FeedHeadlineWidgetSnapshot) throws {
        let data = try JSONEncoder().encode(snapshot)
        userDefaults.set(data, forKey: snapshotKey)
    }

    public func load() throws -> FeedHeadlineWidgetSnapshot? {
        guard let data = userDefaults.data(forKey: snapshotKey) else {
            return nil
        }

        return try JSONDecoder().decode(FeedHeadlineWidgetSnapshot.self, from: data)
    }

    public func clear() throws {
        userDefaults.removeObject(forKey: snapshotKey)
    }
}
