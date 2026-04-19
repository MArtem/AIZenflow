import Foundation
import WidgetKit
import TchopWidgets

/// App-facing contract that synchronizes feed data into widget storage.
@MainActor
protocol WidgetContentSyncing {
    func syncFeed(content: NewsFeedContent)
    func clearFeed()
}

/// No-op implementation used where widget synchronization is unavailable or unnecessary.
@MainActor
final class NoopWidgetContentSyncManager: WidgetContentSyncing {
    init() {}

    func syncFeed(content: NewsFeedContent) {}

    func clearFeed() {}
}

/// Shared widget bridge used by the app to publish widget snapshots.
@MainActor
final class FeedHeadlineWidgetSyncManager: WidgetContentSyncing {
    private let snapshotManager: any FeedHeadlineWidgetSnapshotManaging

    init(snapshotManager: any FeedHeadlineWidgetSnapshotManaging) {
        self.snapshotManager = snapshotManager
    }

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
