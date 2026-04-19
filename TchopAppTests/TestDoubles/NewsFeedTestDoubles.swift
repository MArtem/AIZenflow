@testable import TchopApp

/// Test-only feed loading error cases.
enum TestNewsFeedError: Error {
    case failed
}

/// Lightweight repository double for feed view-model tests.
@MainActor
final class TestNewsFeedRepository: NewsFeedRepository {
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

    /// Returns the configured feed result after the optional delay.
    func fetchNewsFeedContent() async throws -> NewsFeedContent {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }

        return try result.get()
    }
}
