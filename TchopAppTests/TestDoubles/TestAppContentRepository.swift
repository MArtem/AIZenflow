import Foundation
import TchopDatabase
@testable import TchopApp

/// Lightweight in-memory app-content repository used by state/composition tests.
@MainActor
final class TestAppContentRepository: AppContentRepository {
    /// Returns a stable channel snapshot for tests that do not exercise persistence.
    func fetchAvailableChannels() throws -> [AppChannel] {
        [AppChannel.defaultChannel]
    }
}

/// In-memory feed-card persistence double for feed and shell tests.
@MainActor
final class TestFeedCardRepository: FeedCardPersisting {
    private(set) var savedBatches: [[FeedCard]] = []
    private(set) var savedSingleCards: [FeedCard] = []
    private(set) var savedCards: [FeedCard]

    /// Creates a feed-card repository double seeded with already persisted cards.
    init(cards: [FeedCard] = []) {
        self.savedCards = cards
    }

    /// Returns the current persisted card snapshot.
    func loadCards() throws -> [FeedCard] {
        savedCards
    }

    /// Saves a batch of newly published cards.
    func saveCards(_ cards: [FeedCard]) throws {
        savedBatches.append(cards)
        savedCards = cards + savedCards.filter { existingCard in
            !cards.contains(where: { $0.id == existingCard.id })
        }
    }

    /// Saves or updates one persisted card.
    func saveCard(_ card: FeedCard) throws {
        savedSingleCards.append(card)
        if let index = savedCards.firstIndex(where: { $0.id == card.id }) {
            savedCards[index] = card
        } else {
            savedCards.insert(card, at: 0)
        }
    }
}

/// Creates a disposable in-memory SwiftData database manager for app tests.
@MainActor
func makeInMemoryAppDatabaseManager() throws -> any DatabaseManaging {
    try AppDatabase.makeDatabaseManagerOrThrow(
        configuration: DatabaseConfiguration(
            backendSelectionPolicy: .swiftData,
            isStoredInMemoryOnly: true
        )
    )
}

/// Creates a channels store with a deterministic active user/channel snapshot.
@MainActor
func makeTestChannelsStore(
    channels: [AppChannel] = AppChannel.allKnown,
    selectedChannelID: String = AppChannel.defaultChannel.id,
    userID: String = "test-user"
) -> ChannelsStore {
    let userDefaults = UserDefaults(suiteName: "tchop.tests.\(UUID().uuidString)")!
    let store = ChannelsStore(
        selectionStore: UserDefaultsChannelSelectionStore(
            userDefaults: userDefaults,
            keyPrefix: "selected_channel_id.tests"
        )
    )
    store.setAvailableChannels(channels)
    _ = store.activate(for: userID, preferredSelectedChannelID: selectedChannelID)
    return store
}

/// Creates a feed-card store from an in-memory repository double.
@MainActor
func makeTestFeedCardStore(cards: [FeedCard] = []) -> FeedCardStore {
    FeedCardStore(repository: TestFeedCardRepository(cards: cards))
}

/// Creates a valid text feed card for app runtime tests.
func makeTextFeedCard(
    id: String = UUID().uuidString,
    channelID: String = AppChannel.defaultChannel.id,
    text: String,
    headline: String? = nil,
    createdAt: Date = Date(timeIntervalSince1970: 1)
) -> FeedCard {
    var textContent = [
        FeedTextContent(kind: .text, text: text)
    ]
    if let headline {
        textContent.append(FeedTextContent(kind: .headline, text: headline))
    }

    return FeedCard(
        id: id,
        channelID: channelID,
        createdAt: createdAt,
        kind: .text,
        orderedTextContent: textContent,
        sourceContent: nil,
        mediaContent: nil,
        isLiked: false,
        commentsCount: 0,
        displayMode: .expanded
    )
}
