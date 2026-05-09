import Foundation
import CoreData
import SwiftData
import TchopDatabase
@testable import TchopApp

/// Lightweight in-memory repository used by view-model and state tests.
@MainActor
final class TestAppContentRepository: AppContentRepository {
    func fetchAvailableChannels() throws -> [AppChannel] {
        [AppChannel.defaultChannel]
    }

    /// Returns an empty feed fixture for tests that do not care about content mapping.
    func currentNewsFeedContent(channelID: String) throws -> NewsFeedContent? {
        NewsFeedContent(cards: [], availability: .live)
    }

    /// Returns an empty feed fixture for tests that do not care about content mapping.
    func refreshNewsFeedContent(channelID: String) async throws -> NewsFeedContent {
        NewsFeedContent(cards: [], availability: .live)
    }

    func performPhotoAction(
        articleID: String,
        action: PhotoCardAction
    ) async throws -> PhotoCardModel {
        PhotoCardModel(
            id: articleID,
            channelID: AppChannel.defaultChannel.id,
            postedInPrefix: "Posted in ",
            sourceTitle: "Source",
            brandTitle: "Brand",
            headline: "Headline",
            summary: "Summary",
            metadataLine: "Metadata",
            translationLabel: "",
            commentCount: 0,
            actions: [],
            uiState: .idle
        )
    }

    func performTextAction(
        discussionID: String,
        action: TextCardAction
    ) async throws -> TextCardModel {
        TextCardModel(
            id: discussionID,
            channelID: AppChannel.defaultChannel.id,
            categoryTitle: "Category",
            headline: "Headline",
            participants: [],
            replyCount: 0,
            joinedCount: 0,
            uiState: .idle
        )
    }
}

/// Stub feed API manager returning deterministic fixture payloads in tests.
struct TestFeedAPIManager: FeedAPIManaging {
    let result: Result<FeedResponseDTO, Error>

    /// Returns the configured feed response fixture.
    func fetchFeed(channelID: String) async throws -> FeedResponseDTO {
        try result.get()
    }

    func performPhotoAction(
        channelID: String,
        articleID: String,
        action: PhotoCardAction,
        context: PhotoActionContext
    ) async throws -> PhotoDTO {
        throw TestDatabaseError.fetchFailed
    }

    func performTextAction(
        channelID: String,
        discussionID: String,
        action: TextCardAction,
        context: TextActionContext
    ) async throws -> TextDTO {
        throw TestDatabaseError.fetchFailed
    }
}

/// Test-only error for fixture setup failures.
enum TestDatabaseError: Error {
    case fetchFailed
    case insertFailed
}

/// Reachability double that lets repository tests opt into online behavior explicitly.
struct TestNetworkAvailabilityMonitor: NetworkAvailabilityChecking {
    let internetAvailable: Bool

    func isInternetAvailable() async -> Bool {
        internetAvailable
    }
}

/// Creates a disposable in-memory database manager for app tests.
@MainActor
func makeInMemoryAppDatabaseManager(
    backend: DatabaseBackendSelectionPolicy = .swiftData
) -> any DatabaseManaging {
    AppDatabase.makeDatabaseManager(
        configuration: DatabaseConfiguration(
            backendSelectionPolicy: backend,
            isStoredInMemoryOnly: true
        )
    )
}
