@testable import TchopApp

/// Test-only feed loading error cases.
enum TestNewsFeedError: Error {
    case failed
}

/// Lightweight repository double for feed view-model tests.
@MainActor
final class TestNewsFeedRepository: NewsFeedRepository {
    private var results: [Result<NewsFeedContent, Error>]
    private let delayNanoseconds: UInt64
    private(set) var fetchCallCount = 0

    /// Creates a new TestNewsFeedRepository instance.
    init(
        result: Result<NewsFeedContent, Error>,
        delayNanoseconds: UInt64 = 0
    ) {
        self.results = [result]
        self.delayNanoseconds = delayNanoseconds
    }

    /// Creates a new TestNewsFeedRepository instance with a deterministic sequence of results.
    init(
        results: [Result<NewsFeedContent, Error>],
        delayNanoseconds: UInt64 = 0
    ) {
        self.results = results
        self.delayNanoseconds = delayNanoseconds
    }

    func currentNewsFeedContent() throws -> NewsFeedContent? {
        let firstResult = results.first
        guard case let .success(content) = firstResult else {
            return nil
        }

        return content
    }

    /// Returns the configured feed result after the optional delay.
    func refreshNewsFeedContent() async throws -> NewsFeedContent {
        fetchCallCount += 1

        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }

        let result = results.count > 1 ? results.removeFirst() : results[0]

        return try result.get()
    }

    func performFeaturedArticleAction(
        articleID: String,
        action: FeaturedArticleCardAction
    ) async throws -> FeaturedArticleCardModel {
        throw TestNewsFeedError.failed
    }

    func performDiscussionAction(
        discussionID: String,
        action: DiscussionCardAction
    ) async throws -> DiscussionCardModel {
        throw TestNewsFeedError.failed
    }
}
