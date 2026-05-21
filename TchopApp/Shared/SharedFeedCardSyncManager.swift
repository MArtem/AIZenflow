import Foundation
import TchopShareSupport

@MainActor
final class SharedFeedCardSyncManager {
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

    @discardableResult
    func syncPendingCards(into feedCardStore: FeedCardStore) throws -> Int {
        let loadResult = try store.loadAllSafely()
        let cards = loadResult.items.sorted { $0.createdAt > $1.createdAt }

        if !cards.isEmpty {
            try feedCardStore.sync(cards)
            try store.removeItems(withIDs: cards.map(\.id))
        }

        try store.quarantineFiles(loadResult.failedFileURLs)

        return cards.count
    }
}
