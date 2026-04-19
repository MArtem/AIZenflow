import XCTest
import TchopDatabase
@testable import TchopApp

/// Verifies async loading states and error handling for feed view model.
@MainActor
final class NewsFeedViewModelTests: XCTestCase {
    /// Verifies reload loads content from repository.
    func testReloadLoadsContentFromRepository() async {
        let expectedContent = NewsFeedContent(
            cards: [
                .discussion(
                    DiscussionCardModel(
                        id: "discussion",
                        categoryTitle: "Discussion",
                        headline: "Loaded from repository",
                        participants: [],
                        joinedText: "+1 joined"
                    )
                )
            ]
        )
        let repository = TestNewsFeedRepository(result: .success(expectedContent))
        let viewModel = NewsFeedViewModel(
            repository: repository,
            widgetContentSyncManager: NoopWidgetContentSyncManager()
        )

        await waitForLoading(of: viewModel)

        XCTAssertEqual(viewModel.content, expectedContent)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    /// Verifies reload publishes error state on failure.
    func testReloadPublishesErrorStateOnFailure() async {
        let repository = TestNewsFeedRepository(result: .failure(TestNewsFeedError.failed))
        let viewModel = NewsFeedViewModel(
            repository: repository,
            widgetContentSyncManager: NoopWidgetContentSyncManager()
        )

        await waitForLoading(of: viewModel)

        XCTAssertEqual(
            viewModel.errorMessage,
            AppLocalization.text("news.error.loadFailed", fallback: "Failed to load feed.")
        )
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.content.cards.isEmpty)
    }

    /// Verifies cancel loading stops loading state.
    func testCancelLoadingStopsLoadingState() {
        let repository = TestNewsFeedRepository(result: .success(.init(cards: [])), delayNanoseconds: 500_000_000)
        let viewModel = NewsFeedViewModel(
            repository: repository,
            widgetContentSyncManager: NoopWidgetContentSyncManager()
        )

        viewModel.cancelLoading()

        XCTAssertFalse(viewModel.isLoading)
    }

    /// Waits until for loading.
    private func waitForLoading(of viewModel: NewsFeedViewModel) async {
        for _ in 0..<20 {
            if !viewModel.isLoading {
                return
            }

            try? await Task.sleep(nanoseconds: 20_000_000)
        }

        XCTFail("Timed out waiting for feed loading to finish")
    }
}

@MainActor
private final class TestNewsFeedRepository: NewsFeedRepository {
    private let result: Result<NewsFeedContent, Error>
    private let delayNanoseconds: UInt64

    /// Creates a new TestNewsFeedRepository instance.
    init(
        result: Result<NewsFeedContent, Error>,
        delayNanoseconds: UInt64 = 0
    ) {
        self.result = result
        self.delayNanoseconds = delayNanoseconds
    }

    /// Fetches news feed content.
    func fetchNewsFeedContent() async throws -> NewsFeedContent {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }

        return try result.get()
    }
}

private enum TestNewsFeedError: Error {
    case failed
}

@MainActor
/// Verifies persistence-facing user repository behavior.
final class UserRepositoryTests: XCTestCase {
    /// Verifies find user returns nil for whitespace username.
    func testFindUserReturnsNilForWhitespaceUsername() throws {
        let repository = DefaultUserRepository(databaseManager: makeInMemoryAppDatabaseManager())

        let user = try repository.findUser(username: "   ")

        XCTAssertNil(user)
    }

    /// Verifies find or create returns existing user without insert.
    func testFindOrCreateReturnsExistingUserWithoutInsert() throws {
        let databaseManager = makeInMemoryAppDatabaseManager()
        let repository = DefaultUserRepository(databaseManager: databaseManager)
        let createdUser = try repository.findOrCreateUser(username: "alice")

        let user = try repository.findOrCreateUser(username: " alice ")

        XCTAssertEqual(user.username, "alice")
        XCTAssertEqual(user.id, createdUser.id)
    }

    /// Verifies find or create inserts new user inside transaction.
    func testFindOrCreateInsertsNewUserInsideTransaction() throws {
        let databaseManager = makeInMemoryAppDatabaseManager()
        let repository = DefaultUserRepository(databaseManager: databaseManager)

        let user = try repository.findOrCreateUser(username: "bob")

        XCTAssertEqual(user.username, "bob")
        XCTAssertNotNil(try repository.findUser(username: "bob"))
    }

    /// Verifies find or create throws for whitespace username.
    func testFindOrCreateThrowsForWhitespaceUsername() {
        let repository = DefaultUserRepository(databaseManager: makeInMemoryAppDatabaseManager())

        XCTAssertThrowsError(try repository.findOrCreateUser(username: "   "))
    }
}

@MainActor
/// Verifies app-content repository mapping from persistence/API models.
final class AppContentRepositoryTests: XCTestCase {
    /// Verifies fetch channel info maps stored channel.
    func testFetchChannelInfoMapsStoredChannel() throws {
        let databaseManager = makeInMemoryAppDatabaseManager()
        _ = try databaseManager.write(
            DatabaseWriteOperation(coreData: { context in
                let entity = CoreDataChannelEntity(context: context)
                entity.id = "primary-channel"
                entity.title = "Tchop"
                entity.subtitle = "New channel name"
            })
        ) as Void

        let repository = DefaultAppContentRepository(
            databaseManager: databaseManager,
            feedAPIManager: TestFeedAPIManager(result: .success(FeedResponseDTO(cards: [])))
        )

        let channel = try repository.fetchChannelInfo()

        XCTAssertEqual(channel.title, "Tchop")
        XCTAssertEqual(channel.subtitle, "New channel name")
    }

    /// Verifies fetch channel info throws when channel is missing.
    func testFetchChannelInfoThrowsWhenChannelIsMissing() {
        let repository = DefaultAppContentRepository(
            databaseManager: makeInMemoryAppDatabaseManager(),
            feedAPIManager: TestFeedAPIManager(result: .success(FeedResponseDTO(cards: [])))
        )

        XCTAssertThrowsError(try repository.fetchChannelInfo())
    }

    /// Verifies fetch news feed content maps dtos to cards.
    func testFetchNewsFeedContentMapsDTOsToCards() async throws {
        let repository = DefaultAppContentRepository(
            databaseManager: makeInMemoryAppDatabaseManager(),
            feedAPIManager: TestFeedAPIManager(
                result: .success(
                    FeedResponseDTO(
                        cards: [
                            .featuredArticle(
                                FeaturedArticleDTO(
                                    id: "article-1",
                                    postedInPrefix: "Posted in ",
                                    sourceTitle: "Blog",
                                    brandTitle: "Tchop",
                                    headline: "Headline",
                                    summary: "Summary",
                                    metadataLine: "Meta",
                                    translationLabel: "Translate",
                                    actions: [
                                        ArticleActionDTO(
                                            id: "like",
                                            systemName: "hand.thumbsup.fill",
                                            title: "Like"
                                        )
                                    ]
                                )
                            ),
                            .discussion(
                                DiscussionDTO(
                                    id: "discussion-1",
                                    categoryTitle: "Discussion",
                                    headline: "Headline",
                                    participants: [
                                        DiscussionParticipantDTO(
                                            id: "participant-1",
                                            initials: "A",
                                            isHighlighted: true
                                        )
                                    ],
                                    joinedText: "+1 joined"
                                )
                            )
                        ]
                    )
                )
            )
        )

        let content = try await repository.fetchNewsFeedContent()

        XCTAssertEqual(content.cards.count, 2)
    }
}
