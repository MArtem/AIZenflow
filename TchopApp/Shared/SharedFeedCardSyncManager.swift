import Foundation
import TchopShareSupport

/// App-group bridge for feed cards published by the share extension.
///
/// External usage:
/// The extension writes pending cards through this manager; the containing app imports them on
/// activation/refresh into `FeedCardStore`.
///
/// Identity policy:
/// A published `FeedCard.id` is an immutable idempotency key. Re-publishing the same ID represents retrying the
/// same card payload, not publishing a newer revision. New card content must receive a new ID.
///
/// Concurrency:
/// The manager stores only a sendable app-group storage mechanism and owns no mutable in-memory state.
final class SharedFeedCardSyncManager: Sendable {
    private static let pendingCardsDirectoryName = "share-extension-published-cards"

    private let store: AppGroupJSONItemDirectoryStore<FeedCard>

    init(groupIdentifier: String) throws {
        self.store = try AppGroupJSONItemDirectoryStore(
            groupIdentifier: groupIdentifier,
            directoryName: Self.pendingCardsDirectoryName
        )
    }

    init(store: AppGroupJSONItemDirectoryStore<FeedCard>) {
        self.store = store
    }

    func publishImportedCard(_ card: FeedCard) throws {
        try store.save(card)
    }

    func publishImportedCard(_ card: FeedCard) async throws {
        try await store.saveAsync(card)
    }

    @discardableResult
    func syncPendingCards(into feedCardStore: FeedCardStore) async throws -> Int {
        let loadResult = try await store.loadAllSafelyAsync()
        let cards = loadResult.items.sorted { $0.createdAt > $1.createdAt }

        if !cards.isEmpty {
            try await MainActor.run {
                try feedCardStore.sync(cards)
            }
            try await store.removeItemsAsync(withIDs: cards.map(\.id))
        }

        try await store.quarantineFilesAsync(loadResult.failedFileURLs)

        return cards.count
    }
}
