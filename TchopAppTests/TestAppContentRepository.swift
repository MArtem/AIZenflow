import Foundation
import CoreData
import SwiftData
import TchopDatabase
@testable import TchopApp

/// Lightweight in-memory repository used by view-model and state tests.
@MainActor
final class TestAppContentRepository: AppContentRepository {
    func fetchChannelInfo() throws -> ChannelHeaderInfo {
        ChannelHeaderInfo(
            title: "Tchop",
            subtitle: "New channel name"
        )
    }

    func fetchNewsFeedContent() async throws -> NewsFeedContent {
        NewsFeedContent(cards: [])
    }
}

/// Stub feed API manager returning deterministic fixture payloads in tests.
struct TestFeedAPIManager: FeedAPIManaging {
    let result: Result<FeedResponseDTO, Error>

    func fetchFeed() async throws -> FeedResponseDTO {
        try result.get()
    }
}

/// Test-only error for fixture setup failures.
enum TestDatabaseError: Error {
    case fetchFailed
    case insertFailed
}

/// Creates a disposable in-memory database manager for app tests.
@MainActor
func makeInMemoryAppDatabaseManager(
    backend: AppDatabaseBackendSelectionPolicy = .coreData
) -> any DatabaseManaging {
    AppDatabase.makeDatabaseManager(
        configuration: DatabaseConfiguration(
            backendSelectionPolicy: backend,
            isStoredInMemoryOnly: true
        )
    )
}
