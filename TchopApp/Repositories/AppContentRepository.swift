import Foundation
import CoreData
import SwiftData
import TchopDatabase

/// Repository interface for fixed channel header information.
@MainActor
protocol ChannelInfoRepository {
    /// Fetches channel metadata used by the pinned top bar.
    func fetchChannelInfo() throws -> ChannelHeaderInfo
}

/// Repository interface for the news feed timeline.
@MainActor
protocol NewsFeedRepository {
    /// Fetches feed content and maps it into presentation models.
    func fetchNewsFeedContent() async throws -> NewsFeedContent
}

/// Combined repository used by the shell to resolve both channel and feed content.
protocol AppContentRepository: ChannelInfoRepository, NewsFeedRepository {}

/// Default app content repository that combines local persistence and API data.
@MainActor
final class DefaultAppContentRepository: AppContentRepository {
    private let databaseManager: any DatabaseManaging
    private let feedAPIManager: any FeedAPIManaging

    /// Creates a new DefaultAppContentRepository instance.
    init(
        databaseManager: any DatabaseManaging,
        feedAPIManager: any FeedAPIManaging
    ) {
        self.databaseManager = databaseManager
        self.feedAPIManager = feedAPIManager
    }

    /// Fetches channel data from local persistence.
    func fetchChannelInfo() throws -> ChannelHeaderInfo {
        try requireChannelInfo(fetchChannelInfoFromCurrentBackend())
    }

    /// Fetches feed cards from the feed API and maps them into view-facing models.
    func fetchNewsFeedContent() async throws -> NewsFeedContent {
        let response = try await feedAPIManager.fetchFeed()
        return AppContentMapper.mapFeedContent(from: response)
    }

    /// Resolves channel info using the currently selected persistence backend.
    private func fetchChannelInfoFromCurrentBackend() throws -> ChannelHeaderInfo? {
        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return try fetchSwiftDataChannelInfo()
            }

            return try fetchCoreDataChannelInfo()
        case .coreData:
            return try fetchCoreDataChannelInfo()
        }
    }

    /// Converts an optional channel result into a repository-level success or error.
    private func requireChannelInfo(_ channel: ChannelHeaderInfo?) throws -> ChannelHeaderInfo {
        guard let channel else {
            throw RepositoryError.missingChannel
        }

        return channel
    }

    @available(iOS 17, *)
    /// Fetches channel info through the SwiftData backend.
    private func fetchSwiftDataChannelInfo() throws -> ChannelHeaderInfo? {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                let descriptor = FetchDescriptor<ChannelRecord>()
                return try context.fetch(descriptor).first.map(AppContentMapper.mapChannelInfo)
            })
        )
    }

    /// Fetches channel info through the Core Data backend.
    private func fetchCoreDataChannelInfo() throws -> ChannelHeaderInfo? {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataChannelFetchRequest()
                return try context.fetch(request).first.map(AppContentMapper.mapChannelInfo)
            })
        )
    }

    /// Builds a single-record Core Data request for channel metadata.
    private static func makeCoreDataChannelFetchRequest() -> NSFetchRequest<CoreDataChannelEntity> {
        let request = CoreDataChannelEntity.fetchRequest()
        request.fetchLimit = 1
        return request
    }
}

private enum RepositoryError: Error {
    case missingChannel
}

private enum AppContentMapper {
    static func mapFeedContent(from response: FeedResponseDTO) -> NewsFeedContent {
        NewsFeedContent(cards: response.cards.map(mapFeedCard))
    }

    static func mapFeedCard(_ card: FeedCardDTO) -> NewsFeedCard {
        switch card {
        case let .featuredArticle(article):
            return .featuredArticle(mapFeaturedArticle(article))
        case let .discussion(discussion):
            return .discussion(mapDiscussion(discussion))
        }
    }

    static func mapFeaturedArticle(_ article: FeaturedArticleDTO) -> FeaturedArticleCardModel {
        FeaturedArticleCardModel(
            id: article.id,
            postedInPrefix: article.postedInPrefix,
            sourceTitle: article.sourceTitle,
            brandTitle: article.brandTitle,
            headline: article.headline,
            summary: article.summary,
            metadataLine: article.metadataLine,
            translationLabel: article.translationLabel,
            actions: article.actions.map(mapArticleAction)
        )
    }

    static func mapArticleAction(_ action: ArticleActionDTO) -> ArticleActionItem {
        ArticleActionItem(
            id: action.id,
            systemName: action.systemName,
            title: action.title
        )
    }

    static func mapDiscussion(_ discussion: DiscussionDTO) -> DiscussionCardModel {
        DiscussionCardModel(
            id: discussion.id,
            categoryTitle: discussion.categoryTitle,
            headline: discussion.headline,
            participants: discussion.participants.map(mapDiscussionParticipant),
            joinedText: discussion.joinedText
        )
    }

    static func mapDiscussionParticipant(_ participant: DiscussionParticipantDTO) -> DiscussionParticipant {
        DiscussionParticipant(
            id: participant.id,
            initials: participant.initials,
            isHighlighted: participant.isHighlighted
        )
    }

    @available(iOS 17, *)
    static func mapChannelInfo(_ channel: ChannelRecord) -> ChannelHeaderInfo {
        ChannelHeaderInfo(title: channel.title, subtitle: channel.subtitle)
    }

    static func mapChannelInfo(_ channel: CoreDataChannelEntity) -> ChannelHeaderInfo {
        ChannelHeaderInfo(title: channel.title, subtitle: channel.subtitle)
    }
}
