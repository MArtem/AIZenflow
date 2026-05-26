import XCTest
import TchopDatabase
import TchopErrors
@testable import TchopApp

/// Verifies local-created feed-card runtime state, search, interactions, and persistence boundaries.
@MainActor
final class NewsFeedViewModelTests: XCTestCase {
    /// Verifies the feed starts empty when no card is persisted for the selected channel.
    func testInitialStateIsEmptyWhenSelectedChannelHasNoCards() {
        let viewModel = makeViewModel(cards: [])

        XCTAssertEqual(viewModel.state, .empty(NewsFeedContent(cards: [], availability: .live)))
        XCTAssertTrue(viewModel.visibleContent.cards.isEmpty)
        XCTAssertFalse(viewModel.showsNoSearchResults)
    }

    /// Verifies only cards for the selected channel are visible.
    func testVisibleContentScopesCardsToSelectedChannel() {
        let selectedCard = makeTextFeedCard(id: "selected-card", channelID: AppChannel.defaultChannel.id, text: "Visible")
        let otherCard = makeTextFeedCard(id: "other-card", channelID: AppChannel.community.id, text: "Hidden")
        let viewModel = makeViewModel(cards: [selectedCard, otherCard])

        XCTAssertEqual(viewModel.visibleContent.cards.map(\.id), ["selected-card"])
        XCTAssertEqual(viewModel.state, .content(viewModel.visibleContent))
    }

    /// Verifies search ranks higher-priority text fields above lower-priority matches.
    func testSearchFiltersAndRanksByFieldPriority() {
        let headlineMatch = makeTextFeedCard(
            id: "headline-match",
            text: "Body",
            headline: "Revenue Growth"
        )
        let textMatch = makeTextFeedCard(
            id: "text-match",
            text: "Revenue Growth",
            headline: "Body"
        )
        let viewModel = makeViewModel(cards: [headlineMatch, textMatch])

        viewModel.toggleSearchPresentation()
        viewModel.searchQuery = "revenue"

        XCTAssertEqual(viewModel.visibleContent.cards.map(\.id), ["text-match", "headline-match"])
        XCTAssertFalse(viewModel.showsNoSearchResults)
    }

    /// Verifies no-results state is shown only when the selected channel has cards.
    func testSearchNoResultsRequiresCardsInCurrentChannel() {
        let viewModel = makeViewModel(cards: [
            makeTextFeedCard(id: "card-1", text: "Visible")
        ])

        viewModel.toggleSearchPresentation()
        viewModel.searchQuery = "missing"

        XCTAssertTrue(viewModel.visibleContent.cards.isEmpty)
        XCTAssertTrue(viewModel.showsNoSearchResults)
    }

    /// Verifies interaction updates are persisted and reflected in visible feed cards.
    func testCardInteractionsPersistAndRefreshVisibleContent() throws {
        let repository = TestFeedCardRepository(cards: [
            makeTextFeedCard(id: "card-1", text: "Text")
        ])
        let feedCardStore = FeedCardStore(repository: repository)
        let viewModel = makeViewModel(feedCardStore: feedCardStore)

        viewModel.toggleFeedCardLike(cardID: "card-1")
        viewModel.incrementFeedCardComments(cardID: "card-1")
        viewModel.setFeedCardDisplayMode(cardID: "card-1", displayMode: .compact)

        let savedCard = try XCTUnwrap(repository.savedCards.first(where: { $0.id == "card-1" }))
        XCTAssertTrue(savedCard.isLiked)
        XCTAssertEqual(savedCard.commentsCount, 1)
        XCTAssertEqual(savedCard.displayMode, .compact)

        let visibleCard = try XCTUnwrap(viewModel.visibleContent.cards.first)
        XCTAssertEqual(visibleCard.id, "card-1")
    }

    /// Verifies changing selected channel resets search and refreshes the scoped card list.
    func testSelectedChannelChangeResetsSearchAndRefreshesVisibleCards() {
        let channelsStore = makeTestChannelsStore()
        let viewModel = makeViewModel(channelsStore: channelsStore, cards: [
            makeTextFeedCard(id: "product-card", channelID: AppChannel.product.id, text: "Product"),
            makeTextFeedCard(id: "community-card", channelID: AppChannel.community.id, text: "Community")
        ])

        viewModel.toggleSearchPresentation()
        viewModel.searchQuery = "product"
        _ = channelsStore.selectChannel(id: AppChannel.community.id)
        viewModel.handleSelectedChannelChange()

        XCTAssertFalse(viewModel.isSearchPresented)
        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertEqual(viewModel.visibleContent.cards.map(\.id), ["community-card"])
    }

    /// Creates a feed view model from seeded cards.
    private func makeViewModel(cards: [FeedCard]) -> NewsFeedViewModel {
        makeViewModel(feedCardStore: makeTestFeedCardStore(cards: cards))
    }

    /// Creates a feed view model from an explicit channel store and seeded cards.
    private func makeViewModel(
        channelsStore: ChannelsStore,
        cards: [FeedCard]
    ) -> NewsFeedViewModel {
        makeViewModel(
            channelsStore: channelsStore,
            feedCardStore: makeTestFeedCardStore(cards: cards)
        )
    }

    /// Creates a feed view model with explicit store injection.
    private func makeViewModel(
        channelsStore: ChannelsStore = makeTestChannelsStore(),
        feedCardStore: FeedCardStore
    ) -> NewsFeedViewModel {
        return NewsFeedViewModel(
            channelsStore: channelsStore,
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            errorManager: AppErrorManager(),
            feedCardStore: feedCardStore
        )
    }
}

/// Verifies persistence-facing user repository behavior.
@MainActor
final class UserRepositoryTests: XCTestCase {
    /// Verifies find user returns nil for whitespace username.
    func testFindUserReturnsNilForWhitespaceUsername() throws {
        let repository = DefaultUserRepository(databaseManager: try makeInMemoryAppDatabaseManager())

        let user = try repository.findUser(username: "   ")

        XCTAssertNil(user)
    }

    /// Verifies find or create returns existing user without insert.
    func testFindOrCreateReturnsExistingUserWithoutInsert() throws {
        let databaseManager = try makeInMemoryAppDatabaseManager()
        let repository = DefaultUserRepository(databaseManager: databaseManager)
        let createdUser = try repository.findOrCreateUser(username: "alice")

        let user = try repository.findOrCreateUser(username: " alice ")

        XCTAssertEqual(user.username, "alice")
        XCTAssertEqual(user.id, createdUser.id)
    }

    /// Verifies find or create inserts new user inside transaction.
    func testFindOrCreateInsertsNewUserInsideTransaction() throws {
        let databaseManager = try makeInMemoryAppDatabaseManager()
        let repository = DefaultUserRepository(databaseManager: databaseManager)

        let user = try repository.findOrCreateUser(username: "bob")

        XCTAssertEqual(user.username, "bob")
        XCTAssertNotNil(try repository.findUser(username: "bob"))
    }

    /// Verifies find or create throws for whitespace username.
    func testFindOrCreateThrowsForWhitespaceUsername() throws {
        let repository = DefaultUserRepository(databaseManager: try makeInMemoryAppDatabaseManager())

        XCTAssertThrowsError(try repository.findOrCreateUser(username: "   "))
    }
}

/// Verifies app-content and feed-card persistence repository behavior.
@MainActor
final class AppContentRepositoryTests: XCTestCase {
    /// Verifies available channels are mapped from SwiftData records.
    func testFetchAvailableChannelsMapsStoredChannels() throws {
        let databaseManager = try makeInMemoryAppDatabaseManager()
        try seedChannels(databaseManager)
        let repository = DefaultAppContentRepository(databaseManager: databaseManager)

        let channels = try repository.fetchAvailableChannels()

        XCTAssertEqual(channels.map(\.id), [AppChannel.product.id, AppChannel.community.id])
    }

    /// Verifies available-channel fetch throws when the channel table is empty.
    func testFetchAvailableChannelsThrowsWhenChannelIsMissing() throws {
        let repository = DefaultAppContentRepository(databaseManager: try makeInMemoryAppDatabaseManager())

        XCTAssertThrowsError(try repository.fetchAvailableChannels())
    }

    /// Verifies feed-card repository round-trips source-neutral card payloads.
    func testFeedCardRepositorySavesLoadsAndUpdatesCards() throws {
        let databaseManager = try makeInMemoryAppDatabaseManager()
        let repository = FeedCardRepository(databaseManager: databaseManager)
        let card = makeTextFeedCard(id: "card-1", text: "Text", headline: "Headline")

        try repository.saveCards([card])
        var loadedCards = try repository.loadCards()
        XCTAssertEqual(loadedCards, [card])

        let updatedCard = card.replacingInteractionState(
            isLiked: true,
            commentsCount: 2,
            displayMode: .compact
        )
        try repository.saveCard(updatedCard)

        loadedCards = try repository.loadCards()
        XCTAssertEqual(loadedCards, [updatedCard])
    }

    /// Inserts deterministic channel records into the in-memory SwiftData store.
    private func seedChannels(_ databaseManager: any DatabaseManaging) throws {
        try databaseManager.write(
            DatabaseWriteOperation(swiftData: { context in
                context.insert(
                    ChannelRecord(
                        id: AppChannel.product.id,
                        title: AppChannel.product.title,
                        subtitle: AppChannel.product.subtitle
                    )
                )
                context.insert(
                    ChannelRecord(
                        id: AppChannel.community.id,
                        title: AppChannel.community.title,
                        subtitle: AppChannel.community.subtitle
                    )
                )
            })
        ) as Void
    }
}
