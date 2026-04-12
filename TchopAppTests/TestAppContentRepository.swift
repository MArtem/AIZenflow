import Foundation
import CoreData
import SwiftData
import TchopDatabase
@testable import TchopApp

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

struct TestFeedAPIManager: FeedAPIManaging {
    let result: Result<FeedResponseDTO, Error>

    func fetchFeed() async throws -> FeedResponseDTO {
        try result.get()
    }
}

enum TestDatabaseError: Error {
    case fetchFailed
    case insertFailed
}

@MainActor
func makeInMemoryAppDatabaseManager(
    backend: AppDatabaseBackendSelectionPolicy = .swiftData
) -> any DatabaseManaging {
    AppDatabase.makeDatabaseManager(
        configuration: DatabaseConfiguration(
            backendSelectionPolicy: backend,
            isStoredInMemoryOnly: true
        )
    )
}
