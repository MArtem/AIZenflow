import Foundation
import TchopShareSupport

final class SharedFeedCardSyncManager: @unchecked Sendable {
    private static let pendingCardsDirectoryName = "share-extension-published-cards"

    private let store: AppGroupJSONItemDirectoryStore<FeedCard>

    init(groupIdentifier: String) throws {
        self.store = try AppGroupJSONItemDirectoryStore(
            groupIdentifier: groupIdentifier,
            directoryName: Self.pendingCardsDirectoryName
        )
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
