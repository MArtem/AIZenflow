import Foundation
import TchopErrors
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
    private let errorManager: any AppErrorManaging

    /// Creates a new FeedHeadlineWidgetSyncManager instance.
    init(
        snapshotManager: any FeedHeadlineWidgetSnapshotManaging,
        errorManager: any AppErrorManaging
    ) {
        self.snapshotManager = snapshotManager
        self.errorManager = errorManager
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
            reportWidgetFailure(error, operation: "syncFeed")
        }
    }

    /// Clears feed.
    func clearFeed() {
        do {
            try snapshotManager.clear()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            reportWidgetFailure(error, operation: "clearFeed")
        }
    }

    private static func resolveHeadline(from content: NewsFeedContent) -> String? {
        content.primaryServiceHeadline
    }

    /// Normalizes widget-storage failures through the shared app error pipeline before asserting in debug.
    private func reportWidgetFailure(_ error: Error, operation: String) {
        Task { [errorManager] in
            let presentation = await errorManager.presentableError(
                from: error,
                context: AppErrorContext(
                    operation: operation,
                    feature: "widgetSync"
                )
            )
            _ = presentation
        }
    }
}
