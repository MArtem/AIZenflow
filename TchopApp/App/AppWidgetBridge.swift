import Foundation
import WidgetKit
import TchopWidgets

/// App-facing contract that synchronizes feed data into widget storage.
@MainActor
protocol WidgetContentSyncing {
    /// Synchronizes feed.
    func syncFeed(content: NewsFeedContent)
    /// Clears feed.
    func clearFeed()
}

/// No-op implementation used where widget synchronization is unavailable or unnecessary.
@MainActor
final class NoopWidgetContentSyncManager: WidgetContentSyncing {
    /// Creates a new NoopWidgetContentSyncManager instance.
    init() {}

    /// Synchronizes feed.
    func syncFeed(content: NewsFeedContent) {}

    /// Clears feed.
    func clearFeed() {}
}

/// Shared widget bridge used by the app to publish widget snapshots.
@MainActor
final class FeedHeadlineWidgetSyncManager: WidgetContentSyncing {
    private let snapshotManager: any FeedHeadlineWidgetSnapshotManaging

    /// Creates a new FeedHeadlineWidgetSyncManager instance.
    init(snapshotManager: any FeedHeadlineWidgetSnapshotManaging) {
        self.snapshotManager = snapshotManager
    }

    /// Synchronizes feed.
    func syncFeed(content: NewsFeedContent) {
        guard let headline = Self.resolveHeadline(from: content) else {
            return
        }

        do {
            try snapshotManager.save(FeedHeadlineWidgetSnapshot(headline: headline))
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            assertionFailure("Failed to sync feed headline widget snapshot: \(error)")
        }
    }

    /// Clears feed.
    func clearFeed() {
        do {
            try snapshotManager.clear()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            assertionFailure("Failed to clear feed headline widget snapshot: \(error)")
        }
    }

    private static func resolveHeadline(from content: NewsFeedContent) -> String? {
        guard let firstCard = content.cards.first else {
            return nil
        }

        switch firstCard {
        case let .featuredArticle(article):
            return article.headline.replacingOccurrences(of: "\n", with: " ")
        case let .discussion(discussion):
            return discussion.headline.replacingOccurrences(of: "\n", with: " ")
        }
    }
}
