import Foundation
import CoreData
import SwiftData
import TchopDatabase
@testable import TchopApp

/// Lightweight in-memory repository used by view-model and state tests.
@MainActor
final class TestAppContentRepository: AppContentRepository {
    /// Returns a fixed channel header fixture.
    func fetchChannelInfo() throws -> ChannelHeaderInfo {
        ChannelHeaderInfo(
            title: "Tchop",
            subtitle: "New channel name"
        )
    }

    /// Returns an empty feed fixture for tests that do not care about content mapping.
    func currentNewsFeedContent() throws -> NewsFeedContent? {
        NewsFeedContent(cards: [], availability: .live)
    }

    /// Returns an empty feed fixture for tests that do not care about content mapping.
    func refreshNewsFeedContent() async throws -> NewsFeedContent {
        NewsFeedContent(cards: [], availability: .live)
    }

    func performFeaturedArticleAction(
        articleID: String,
        action: FeaturedArticleCardAction
    ) async throws -> FeaturedArticleCardModel {
        FeaturedArticleCardModel(
            id: articleID,
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

    func performDiscussionAction(
        discussionID: String,
        action: DiscussionCardAction
    ) async throws -> DiscussionCardModel {
        DiscussionCardModel(
            id: discussionID,
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
    func fetchFeed() async throws -> FeedResponseDTO {
        try result.get()
    }

    func performFeaturedArticleAction(
        articleID: String,
        action: FeaturedArticleCardAction,
        context: FeaturedArticleActionContext
    ) async throws -> FeaturedArticleDTO {
        throw TestDatabaseError.fetchFailed
    }

    func performDiscussionAction(
        discussionID: String,
        action: DiscussionCardAction,
        context: DiscussionActionContext
    ) async throws -> DiscussionDTO {
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
    let isInternetAvailable: Bool
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
