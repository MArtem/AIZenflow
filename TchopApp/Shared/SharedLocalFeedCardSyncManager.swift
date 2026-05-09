import Foundation
import TchopShareSupport

@MainActor
final class SharedLocalFeedCardSyncManager {
    private static let pendingCardsDirectoryName = "share-extension-published-cards"

    private let store: AppGroupJSONItemDirectoryStore<LocalFeedCardModel>

    init(store: AppGroupJSONItemDirectoryStore<LocalFeedCardModel>) {
        self.store = store
    }

    convenience init(groupIdentifier: String) throws {
        try self.init(
            store: AppGroupJSONItemDirectoryStore(
                groupIdentifier: groupIdentifier,
                directoryName: Self.pendingCardsDirectoryName
            )
        )
    }

    func publishImportedCard(_ card: LocalFeedCardModel) throws {
        try store.save(card)
    }

    @discardableResult
    func syncPendingCards(into localFeedCardStore: LocalFeedCardStore) throws -> Int {
        let cards = try store.loadAll()
            .sorted { $0.createdAt > $1.createdAt }

        guard !cards.isEmpty else {
            return 0
        }

        localFeedCardStore.sync(cards)
        try store.clear()

        return cards.count
    }
}
