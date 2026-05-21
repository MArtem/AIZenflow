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
        let cards = try store.loadAll()
            .sorted { $0.createdAt > $1.createdAt }

        guard !cards.isEmpty else {
            return 0
        }

        try feedCardStore.sync(cards)
        try store.clear()

        return cards.count
    }
}
