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

        viewModel.send(.searchPresentationToggled)
        viewModel.searchQuery = "revenue"

        XCTAssertEqual(viewModel.visibleContent.cards.map(\.id), ["text-match", "headline-match"])
        XCTAssertFalse(viewModel.showsNoSearchResults)
    }

    /// Verifies no-results state is shown only when the selected channel has cards.
    func testSearchNoResultsRequiresCardsInCurrentChannel() {
        let viewModel = makeViewModel(cards: [
            makeTextFeedCard(id: "card-1", text: "Visible")
        ])

        viewModel.send(.searchPresentationToggled)
        viewModel.searchQuery = "missing"

        XCTAssertTrue(viewModel.visibleContent.cards.isEmpty)
        XCTAssertTrue(viewModel.showsNoSearchResults)
    }

    /// Verifies source-neutral feed cards expose search fields in the product text order.
    func testFeedCardSearchFieldsFollowTextHeadlineSubheadlineSourceOrder() {
        let card = FeedCard(
            id: "card-1",
            channelID: AppChannel.defaultChannel.id,
            createdAt: Date(timeIntervalSince1970: 1),
            kind: .text,
            orderedTextContent: [
                FeedTextContent(kind: .text, text: "Body"),
                FeedTextContent(kind: .headline, text: "Headline"),
                FeedTextContent(kind: .subheadline, text: "Subheadline")
            ],
            sourceContent: FeedSourceContent(text: "Source", resourceURLString: "https://example.com"),
            mediaContent: nil,
            isLiked: false,
            commentsCount: 0,
            displayMode: .expanded
        )

        XCTAssertEqual(card.searchFields.map(\.priority), [500, 400, 300, 200])
        XCTAssertEqual(card.searchFields.map(\.value), ["Body", "Headline", "Subheadline", "Source"])
    }

    /// Verifies interaction updates are persisted and reflected in visible feed cards.
    func testCardInteractionsPersistAndRefreshVisibleContent() throws {
        let repository = TestFeedCardRepository(cards: [
            makeTextFeedCard(id: "card-1", text: "Text")
        ])
        let feedCardStore = FeedCardStore(repository: repository)
        let viewModel = makeViewModel(feedCardStore: feedCardStore)

        viewModel.send(.cardLikeTapped(cardID: "card-1"))
        viewModel.send(.cardCommentsTapped(cardID: "card-1"))
        viewModel.send(.cardDisplayModeChanged(cardID: "card-1", displayMode: .compact))

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

        viewModel.send(.searchPresentationToggled)
        viewModel.searchQuery = "product"
        _ = channelsStore.selectChannel(id: AppChannel.community.id)
        viewModel.send(.selectedChannelChanged)

        XCTAssertFalse(viewModel.isSearchPresented)
        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertEqual(viewModel.visibleContent.cards.map(\.id), ["community-card"])
    }


    /// Verifies whitespace-only search behaves like no query and does not enter no-results state.
    func testWhitespaceSearchKeepsCurrentChannelCardsVisible() {
        let viewModel = makeViewModel(cards: [
            makeTextFeedCard(id: "card-1", text: "Visible")
        ])

        viewModel.send(.searchPresentationToggled)
        viewModel.searchQuery = "      "

        XCTAssertEqual(viewModel.visibleContent.cards.map(\.id), ["card-1"])
        XCTAssertFalse(viewModel.showsNoSearchResults)
        XCTAssertEqual(viewModel.state, .content(viewModel.visibleContent))
    }

    /// Verifies multiple search tokens must match within one prioritized field.
    func testSearchRequiresAllTokensWithinSameField() {
        let splitTokenCard = makeTextFeedCard(
            id: "split-token-card",
            text: "Revenue",
            headline: "Growth"
        )
        let sameFieldCard = makeTextFeedCard(
            id: "same-field-card",
            text: "Revenue Growth"
        )
        let viewModel = makeViewModel(cards: [splitTokenCard, sameFieldCard])

        viewModel.send(.searchPresentationToggled)
        viewModel.searchQuery = "revenue growth"

        XCTAssertEqual(viewModel.visibleContent.cards.map(\.id), ["same-field-card"])
    }

    /// Verifies equal-priority search matches preserve the current feed order.
    func testSearchPreservesFeedOrderForEqualPriorityMatches() {
        let firstCard = makeTextFeedCard(id: "first-card", text: "Release notes")
        let secondCard = makeTextFeedCard(id: "second-card", text: "Release update")
        let viewModel = makeViewModel(cards: [firstCard, secondCard])

        viewModel.send(.searchPresentationToggled)
        viewModel.searchQuery = "release"

        XCTAssertEqual(viewModel.visibleContent.cards.map(\.id), ["first-card", "second-card"])
    }

    /// Verifies hiding search clears the query and restores the full selected-channel snapshot.
    func testToggleSearchOffClearsQueryAndRestoresVisibleCards() {
        let viewModel = makeViewModel(cards: [
            makeTextFeedCard(id: "alpha-card", text: "Alpha"),
            makeTextFeedCard(id: "beta-card", text: "Beta")
        ])

        viewModel.send(.searchPresentationToggled)
        viewModel.searchQuery = "alpha"
        XCTAssertEqual(viewModel.visibleContent.cards.map(\.id), ["alpha-card"])

        viewModel.send(.searchPresentationToggled)

        XCTAssertFalse(viewModel.isSearchPresented)
        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertEqual(viewModel.visibleContent.cards.map(\.id), ["alpha-card", "beta-card"])
    }

    /// Verifies syncing a duplicate feed card does not overwrite the persisted runtime card.
    func testFeedCardStoreSyncIgnoresDuplicateCardIDs() throws {
        let originalCard = makeTextFeedCard(id: "card-1", text: "Original")
        let duplicateCard = makeTextFeedCard(id: "card-1", text: "Duplicate")
        let repository = TestFeedCardRepository(cards: [originalCard])
        let feedCardStore = FeedCardStore(repository: repository)

        try feedCardStore.sync([duplicateCard])

        XCTAssertTrue(repository.savedBatches.isEmpty)
        XCTAssertEqual(repository.savedCards, [originalCard])
        XCTAssertEqual(feedCardStore.cards.map(\.id), ["card-1"])
        XCTAssertEqual(feedCardStore.cards.first?.serviceHeadline, "Original")
    }

    /// Verifies single-card interaction persistence updates only the targeted card.
    func testFeedCardStoreUpdatePersistsOnlyTargetedCard() throws {
        let firstCard = makeTextFeedCard(id: "first-card", text: "First")
        let secondCard = makeTextFeedCard(id: "second-card", text: "Second")
        let repository = TestFeedCardRepository(cards: [firstCard, secondCard])
        let feedCardStore = FeedCardStore(repository: repository)

        feedCardStore.updatePersistedCard(id: "second-card") { card in
            card.replacingInteractionState(isLiked: true, commentsCount: 3, displayMode: .compact)
        }

        XCTAssertEqual(repository.savedSingleCards.map(\.id), ["second-card"])
        XCTAssertEqual(repository.savedCards.map(\.id), ["first-card", "second-card"])
        XCTAssertFalse(repository.savedCards[0].isLiked)
        XCTAssertTrue(repository.savedCards[1].isLiked)
        XCTAssertEqual(repository.savedCards[1].commentsCount, 3)
        XCTAssertEqual(repository.savedCards[1].displayMode, .compact)
        XCTAssertEqual(feedCardStore.cards.map(\.id), ["first-card", "second-card"])
    }

    /// Verifies updating a missing feed card is a no-op against persistence.
    func testFeedCardStoreUpdateMissingCardDoesNotPersist() {
        let repository = TestFeedCardRepository(cards: [
            makeTextFeedCard(id: "card-1", text: "Text")
        ])
        let feedCardStore = FeedCardStore(repository: repository)

        feedCardStore.updatePersistedCard(id: "missing-card") { card in
            card.replacingInteractionState(isLiked: true)
        }

        XCTAssertTrue(repository.savedSingleCards.isEmpty)
        XCTAssertEqual(repository.savedCards.map(\.id), ["card-1"])
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


/// Verifies source-neutral feed-card model contracts that must stay stable across composer, persistence, feed, and translation flows.
final class NewsFeedModelContractTests: XCTestCase {
    /// Verifies composer content trims text fields and preserves canonical text/headline/subheadline/source order.
    func testChannelCardContentOrderedTextContentTrimsAndPreservesCanonicalOrder() {
        let content = ChannelCardContent(
            id: "content-1",
            channelID: AppChannel.defaultChannel.id,
            createdAt: Date(timeIntervalSince1970: 1),
            kind: .text,
            text: "  Body  ",
            headline: "\nHeadline\n",
            subheadline: "   Subheadline   ",
            source: "  Source  ",
            media: nil
        )

        XCTAssertEqual(content.orderedTextContent.map(\.kind), [.text, .headline, .subheadline, .source])
        XCTAssertEqual(content.orderedTextContent.map(\.text), ["Body", "Headline", "Subheadline", "Source"])
    }

    /// Verifies old persisted feed cards without interaction fields decode into safe runtime defaults.
    func testFeedCardDecodeDefaultsInteractionStateWhenFieldsAreMissing() throws {
        let json = """
        {
          "id": "card-1",
          "channelID": "\(AppChannel.defaultChannel.id)",
          "createdAt": 1,
          "kind": "text",
          "orderedTextContent": [
            { "kind": "text", "text": "Persisted body" }
          ]
        }
        """.data(using: .utf8)!

        let card = try JSONDecoder().decode(FeedCard.self, from: json)

        XCTAssertFalse(card.isLiked)
        XCTAssertEqual(card.commentsCount, 0)
        XCTAssertEqual(card.displayMode, .expanded)
    }

    /// Verifies translation payload trims empty fields and does not include source text.
    func testFeedCardTranslationPayloadTrimsEmptyFieldsAndExcludesSource() {
        let card = FeedCard(
            id: "card-1",
            channelID: AppChannel.defaultChannel.id,
            createdAt: Date(timeIntervalSince1970: 1),
            kind: .text,
            orderedTextContent: [
                FeedTextContent(kind: .text, text: "  Body  "),
                FeedTextContent(kind: .headline, text: "   "),
                FeedTextContent(kind: .subheadline, text: " Subheadline "),
                FeedTextContent(kind: .source, text: "Source must not translate")
            ],
            sourceContent: FeedSourceContent(text: "Visible source", resourceURLString: nil),
            mediaContent: nil,
            isLiked: false,
            commentsCount: 0,
            displayMode: .expanded
        )

        let payload = card.newsFeedCard.translationPayload

        XCTAssertEqual(payload.cardID, "card-1")
        XCTAssertEqual(payload.fields, [.text: "Body", .subheadline: "Subheadline"])
    }

    /// Verifies channel scoping is nil-safe and preserves feed availability metadata.
    func testNewsFeedContentScopeNilReturnsEmptyContentAndPreservesAvailability() {
        let availability = NewsFeedAvailability.cached(
            lastSyncedAt: Date(timeIntervalSince1970: 5),
            reason: .offline
        )
        let content = NewsFeedContent(
            cards: [makeTextFeedCard(id: "card-1", text: "Body").newsFeedCard],
            availability: availability
        )

        let scopedContent = content.scoped(to: nil)

        XCTAssertTrue(scopedContent.cards.isEmpty)
        XCTAssertEqual(scopedContent.availability, availability)
    }

    /// Verifies feed-card detail routing uses headline/text/source fallbacks without exposing storage details.
    func testFeedCardDetailRouteUsesHeadlineTextAndSourceFallbacks() {
        let card = FeedCard(
            id: "card-1",
            channelID: AppChannel.defaultChannel.id,
            createdAt: Date(timeIntervalSince1970: 1),
            kind: .text,
            orderedTextContent: [
                FeedTextContent(kind: .text, text: "Body"),
                FeedTextContent(kind: .headline, text: "Headline"),
                FeedTextContent(kind: .subheadline, text: "Subheadline")
            ],
            sourceContent: FeedSourceContent(text: "Source", resourceURLString: nil),
            mediaContent: nil,
            isLiked: false,
            commentsCount: 0,
            displayMode: .expanded
        )

        let route = card.detailRoute

        XCTAssertEqual(route.cardID, "card-1")
        XCTAssertEqual(route.destinationID, "text-details")
        XCTAssertEqual(route.title, "Headline")
        XCTAssertEqual(route.bodyText, "Body")
        XCTAssertEqual(route.subtitle, "Source")
    }

    /// Verifies composer media display titles stay deterministic for photo counts and file media.
    func testChannelCardMediaContentDisplayTitleUsesPhotoCountOrFileTitle() {
        let photos = ChannelCardMediaContent.photos(items: [
            ChannelCardPhotoItem(id: "photo-1", displayTitle: "First", fileURL: nil, caption: nil, copyright: nil),
            ChannelCardPhotoItem(id: "photo-2", displayTitle: "Second", fileURL: nil, caption: nil, copyright: nil)
        ])
        let pdf = ChannelCardMediaContent.file(
            ChannelCardFileMediaContent(
                kind: .pdf,
                displayTitle: "Document.pdf",
                fileURL: nil,
                teaserImage: nil,
                caption: nil
            )
        )

        XCTAssertEqual(photos.displayTitle, "2 Photos")
        XCTAssertEqual(pdf.displayTitle, "Document.pdf")
    }
}

/// Verifies per-card action coordinator queue and cancellation contracts.
@MainActor
final class NewsFeedCardActionCoordinatorTests: XCTestCase {
    /// Verifies queued additive actions are consumed exactly once per queued action.
    func testQueuedAdditiveActionsAreConsumedInOrderAndThenCleared() {
        let coordinator = NewsFeedCardActionCoordinator()

        coordinator.queueAdditiveAction(for: "card-1")
        coordinator.queueAdditiveAction(for: "card-1")

        XCTAssertTrue(coordinator.consumeQueuedAdditiveAction(for: "card-1"))
        XCTAssertTrue(coordinator.consumeQueuedAdditiveAction(for: "card-1"))
        XCTAssertFalse(coordinator.consumeQueuedAdditiveAction(for: "card-1"))
    }

    /// Verifies clearing one card action does not affect another card's queued work.
    func testClearRemovesOnlyTargetCardState() {
        let coordinator = NewsFeedCardActionCoordinator()
        coordinator.queueAdditiveAction(for: "card-1")
        coordinator.queueAdditiveAction(for: "card-2")

        coordinator.clear(cardID: "card-1")

        XCTAssertFalse(coordinator.consumeQueuedAdditiveAction(for: "card-1"))
        XCTAssertTrue(coordinator.consumeQueuedAdditiveAction(for: "card-2"))
    }

    /// Verifies cancelAll cancels active card tasks and clears queued additive actions.
    func testCancelAllCancelsActiveTasksAndClearsQueues() async {
        let coordinator = NewsFeedCardActionCoordinator()
        let cancellationExpectation = expectation(description: "Task cancelled")
        let task = Task {
            do {
                try await Task.sleep(for: .seconds(30))
            } catch is CancellationError {
                cancellationExpectation.fulfill()
            } catch {
                XCTFail("Unexpected task error: \\(error)")
            }
        }

        coordinator.start(task, for: "card-1")
        coordinator.queueAdditiveAction(for: "card-1")
        coordinator.cancelAll()

        await fulfillment(of: [cancellationExpectation], timeout: 2)
        XCTAssertFalse(coordinator.consumeQueuedAdditiveAction(for: "card-1"))
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


    /// Verifies persisted cards are loaded newest-first regardless of save input order.
    func testFeedCardRepositoryLoadsCardsNewestFirst() throws {
        let databaseManager = try makeInMemoryAppDatabaseManager()
        let repository = FeedCardRepository(databaseManager: databaseManager)
        let olderCard = makeTextFeedCard(
            id: "older-card",
            text: "Older",
            createdAt: Date(timeIntervalSince1970: 1)
        )
        let newerCard = makeTextFeedCard(
            id: "newer-card",
            text: "Newer",
            createdAt: Date(timeIntervalSince1970: 2)
        )

        try repository.saveCards([olderCard, newerCard])

        XCTAssertEqual(try repository.loadCards().map(\.id), ["newer-card", "older-card"])
    }

    /// Verifies saving one card can insert a new record without requiring a batch call.
    func testFeedCardRepositorySaveCardInsertsMissingCard() throws {
        let databaseManager = try makeInMemoryAppDatabaseManager()
        let repository = FeedCardRepository(databaseManager: databaseManager)
        let card = makeTextFeedCard(id: "card-1", text: "Inserted")

        try repository.saveCard(card)

        XCTAssertEqual(try repository.loadCards(), [card])
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
