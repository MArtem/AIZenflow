import XCTest
@testable import TchopApp

@MainActor
final class NewsFeedViewModelTests: XCTestCase {
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
        let viewModel = NewsFeedViewModel(repository: repository)

        await waitForLoading(of: viewModel)

        XCTAssertEqual(viewModel.content, expectedContent)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testReloadPublishesErrorStateOnFailure() async {
        let repository = TestNewsFeedRepository(result: .failure(TestNewsFeedError.failed))
        let viewModel = NewsFeedViewModel(repository: repository)

        await waitForLoading(of: viewModel)

        XCTAssertEqual(viewModel.errorMessage, "Failed to load feed.")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.content.cards.isEmpty)
    }

    func testCancelLoadingStopsLoadingState() {
        let repository = TestNewsFeedRepository(result: .success(.init(cards: [])), delayNanoseconds: 500_000_000)
        let viewModel = NewsFeedViewModel(repository: repository)

        viewModel.cancelLoading()

        XCTAssertFalse(viewModel.isLoading)
    }

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

    init(
        result: Result<NewsFeedContent, Error>,
        delayNanoseconds: UInt64 = 0
    ) {
        self.result = result
        self.delayNanoseconds = delayNanoseconds
    }

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
final class UserRepositoryTests: XCTestCase {
    func testFindUserReturnsNilForWhitespaceUsername() throws {
        let repository = DefaultUserRepository(databaseManager: TestAppDatabaseManager())

        let user = try repository.findUser(username: "   ")

        XCTAssertNil(user)
    }

    func testFindOrCreateReturnsExistingUserWithoutInsert() throws {
        let databaseManager = TestAppDatabaseManager()
        let existingUser = StoredUser(
            id: "existing",
            username: "alice",
            createdAt: Date(timeIntervalSince1970: 1)
        )
        databaseManager.storedUsers["alice"] = existingUser
        let repository = DefaultUserRepository(databaseManager: databaseManager)

        let user = try repository.findOrCreateUser(username: " alice ")

        XCTAssertEqual(user.username, "alice")
        XCTAssertEqual(user.id, "existing")
        XCTAssertTrue(databaseManager.insertedUsers.isEmpty)
    }

    func testFindOrCreateInsertsNewUserInsideTransaction() throws {
        let databaseManager = TestAppDatabaseManager()
        let repository = DefaultUserRepository(databaseManager: databaseManager)

        let user = try repository.findOrCreateUser(username: "bob")

        XCTAssertEqual(user.username, "bob")
        XCTAssertEqual(databaseManager.transactionCallCount, 1)
        XCTAssertEqual(databaseManager.insertedUsers.count, 1)
    }
}

@MainActor
final class AppContentRepositoryTests: XCTestCase {
    func testFetchChannelInfoMapsStoredChannel() throws {
        let databaseManager = TestAppDatabaseManager()
        databaseManager.storedChannel = StoredChannel(
            id: "primary-channel",
            title: "Tchop",
            subtitle: "New channel name"
        )
        let repository = DefaultAppContentRepository(
            databaseManager: databaseManager,
            feedAPIManager: TestFeedAPIManager(result: .success(FeedResponseDTO(cards: [])))
        )

        let channel = try repository.fetchChannelInfo()

        XCTAssertEqual(channel.title, "Tchop")
        XCTAssertEqual(channel.subtitle, "New channel name")
    }

    func testFetchChannelInfoThrowsWhenChannelIsMissing() {
        let repository = DefaultAppContentRepository(
            databaseManager: TestAppDatabaseManager(),
            feedAPIManager: TestFeedAPIManager(result: .success(FeedResponseDTO(cards: [])))
        )

        XCTAssertThrowsError(try repository.fetchChannelInfo())
    }

    func testFetchNewsFeedContentMapsDTOsToCards() async throws {
        let repository = DefaultAppContentRepository(
            databaseManager: TestAppDatabaseManager(),
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
