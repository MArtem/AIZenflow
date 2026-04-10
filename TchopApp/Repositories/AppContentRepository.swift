import Foundation

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
    private let databaseManager: any AppDatabaseManaging
    private let feedAPIManager: any FeedAPIManaging

    init(
        databaseManager: any AppDatabaseManaging,
        feedAPIManager: any FeedAPIManaging
    ) {
        self.databaseManager = databaseManager
        self.feedAPIManager = feedAPIManager
    }

    /// Fetches channel data from local persistence.
    func fetchChannelInfo() throws -> ChannelHeaderInfo {
        let channel = try databaseManager.fetchPrimaryChannel()

        guard let channel else {
            throw RepositoryError.missingChannel
        }

        return ChannelHeaderInfo(
            title: channel.title,
            subtitle: channel.subtitle
        )
    }

    /// Fetches feed cards from the feed API and maps them into view-facing models.
    func fetchNewsFeedContent() async throws -> NewsFeedContent {
        let response = try await feedAPIManager.fetchFeed()

        return NewsFeedContent(
            cards: response.cards.map { card in
                switch card {
                case let .featuredArticle(article):
                    return .featuredArticle(
                        FeaturedArticleCardModel(
                            id: article.id,
                            postedInPrefix: article.postedInPrefix,
                            sourceTitle: article.sourceTitle,
                            brandTitle: article.brandTitle,
                            headline: article.headline,
                            summary: article.summary,
                            metadataLine: article.metadataLine,
                            translationLabel: article.translationLabel,
                            actions: article.actions.map { action in
                                ArticleActionItem(
                                    id: action.id,
                                    systemName: action.systemName,
                                    title: action.title
                                )
                            }
                        )
                    )
                case let .discussion(discussion):
                    return .discussion(
                        DiscussionCardModel(
                            id: discussion.id,
                            categoryTitle: discussion.categoryTitle,
                            headline: discussion.headline,
                            participants: discussion.participants.map { participant in
                                DiscussionParticipant(
                                    id: participant.id,
                                    initials: participant.initials,
                                    isHighlighted: participant.isHighlighted
                                )
                            },
                            joinedText: discussion.joinedText
                        )
                    )
                }
            }
        )
    }
}

private enum RepositoryError: Error {
    case missingChannel
}
