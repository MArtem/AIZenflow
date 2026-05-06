import Foundation

enum ChannelCardKind: String, Equatable, Sendable {
    case text
    case photo
    case video
    case audio
    case pdf
}

enum ChannelCardMediaKind: String, Equatable, Sendable {
    case photo
    case video
    case audio
    case pdf
}

enum ChannelCardTextFieldKind: String, CaseIterable, Equatable, Sendable, Identifiable {
    case text
    case headline
    case subheadline
    case source

    var id: String { rawValue }

    var title: String {
        switch self {
        case .text: return "Text"
        case .headline: return "Headline"
        case .subheadline: return "Subheadline"
        case .source: return "Source"
        }
    }

    var placeholder: String {
        switch self {
        case .text: return "Enter card text..."
        case .headline: return "Add headline"
        case .subheadline: return "Add subheadline"
        case .source: return "Add source"
        }
    }
}

enum FeedComposerInsertion: Equatable, Sendable, Identifiable {
    case photoOrVideo
    case audio
    case pdf
    case headline
    case subheadline
    case source

    var id: String { title }

    var title: String {
        switch self {
        case .photoOrVideo: return "Photo or Video"
        case .audio: return "Audio"
        case .pdf: return "PDF"
        case .headline: return "Headline"
        case .subheadline: return "Subheadline"
        case .source: return "Source"
        }
    }
}

struct ChannelCardContent: Identifiable, Equatable, Sendable {
    let id: String
    let channelID: String
    let createdAt: Date
    let kind: ChannelCardKind
    let text: String?
    let headline: String?
    let subheadline: String?
    let source: String?
    let mediaKind: ChannelCardMediaKind?

    var orderedTextBlocks: [String] {
        [text, headline, subheadline, source].compactMap { value in
            guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
                return nil
            }
            return trimmed
        }
    }

    var serviceHeadline: String {
        orderedTextBlocks.first ?? kind.rawValue.capitalized
    }
}

/// Origin metadata for the feed content currently shown to the user.
enum NewsFeedAvailability: Equatable, Sendable {
    case live
    /// Content restored from local persistence rather than a fresh network-backed refresh.
    case cached(lastSyncedAt: Date?, reason: NewsFeedCacheReason)
}

/// Reason why the current feed content comes from persisted storage.
enum NewsFeedCacheReason: Equatable, Sendable {
    case bootstrap
    case offline
}

/// Root presentation model for the news tab feed.
struct NewsFeedContent: Equatable, Sendable {
    /// Ordered card list shown in the feed.
    let cards: [NewsFeedCard]
    let availability: NewsFeedAvailability

    /// Headline best suited for service consumers such as widgets.
    var primaryServiceHeadline: String? {
        cards.first?.serviceHeadline
    }

    /// Returns only the cards belonging to the provided channel while preserving availability metadata.
    func scoped(to channelID: String?) -> NewsFeedContent {
        guard let channelID else {
            return NewsFeedContent(cards: [], availability: availability)
        }

        return NewsFeedContent(
            cards: cards.filter { $0.channelID == channelID },
            availability: availability
        )
    }
}

/// Stable feed card categories used by cross-card UI logic such as search and future create/edit flows.
enum NewsFeedCardKind: String, Equatable, Sendable {
    case featuredArticle
    case discussion
    case channelCard
}

/// Search field metadata used to rank card matches without hardcoding search behavior inside each screen.
struct NewsFeedCardSearchField: Equatable, Sendable {
    let priority: Int
    let value: String
}

/// Feed card variants currently supported by the home timeline.
enum NewsFeedCard: Identifiable, Equatable, Sendable {
    case featuredArticle(FeaturedArticleCardModel)
    case discussion(DiscussionCardModel)
    case channelCard(ChannelCardContent)

    /// Stable identity forwarded from the underlying card model.
    var id: String {
        switch self {
        case let .featuredArticle(card):
            return card.id
        case let .discussion(card):
            return card.id
        case let .channelCard(card):
            return card.id
        }
    }

    /// Stable card category used by generic feed flows.
    var kind: NewsFeedCardKind {
        switch self {
        case .featuredArticle:
            return .featuredArticle
        case .discussion:
            return .discussion
        case .channelCard:
            return .channelCard
        }
    }

    /// Owning channel for the card.
    var channelID: String {
        switch self {
        case let .featuredArticle(card):
            return card.channelID
        case let .discussion(card):
            return card.channelID
        case let .channelCard(card):
            return card.channelID
        }
    }

    /// Service-facing headline derived from the underlying card content.
    var serviceHeadline: String {
        switch self {
        case let .featuredArticle(card):
            return card.serviceHeadline
        case let .discussion(card):
            return card.serviceHeadline
        case let .channelCard(card):
            return card.serviceHeadline
        }
    }

    /// Prioritized search fields used by channel-local search ranking.
    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .featuredArticle(article):
            return [
                NewsFeedCardSearchField(priority: 500, value: article.headline),
                NewsFeedCardSearchField(priority: 400, value: article.summary),
                NewsFeedCardSearchField(priority: 300, value: article.sourceTitle),
                NewsFeedCardSearchField(priority: 250, value: article.brandTitle),
                NewsFeedCardSearchField(priority: 200, value: article.metadataLine),
                NewsFeedCardSearchField(priority: 150, value: article.translationLabel)
            ]
        case let .discussion(discussion):
            return [
                NewsFeedCardSearchField(priority: 500, value: discussion.headline),
                NewsFeedCardSearchField(priority: 300, value: discussion.categoryTitle),
                NewsFeedCardSearchField(
                    priority: 120,
                    value: discussion.participants.map(\.initials).joined(separator: " ")
                )
            ]
        case let .channelCard(card):
            return [
                NewsFeedCardSearchField(priority: 500, value: card.text ?? ""),
                NewsFeedCardSearchField(priority: 400, value: card.headline ?? ""),
                NewsFeedCardSearchField(priority: 300, value: card.subheadline ?? ""),
                NewsFeedCardSearchField(priority: 200, value: card.source ?? "")
            ]
        }
    }
}

/// Presentation model for the featured article card.
struct FeaturedArticleCardModel: Identifiable, Equatable, Sendable {
    let id: String
    let channelID: String
    let postedInPrefix: String
    let sourceTitle: String
    let brandTitle: String
    let headline: String
    let summary: String
    let metadataLine: String
    let translationLabel: String
    let commentCount: Int
    let actions: [ArticleActionItem]
    let uiState: FeaturedArticleCardUIState

    /// Headline formatted for service consumers that should not receive multiline text.
    var serviceHeadline: String {
        headline.replacingOccurrences(of: "\n", with: " ")
    }

    /// Destination payload used by callers that open article details.
    var detailRoute: NewsRoute {
        NewsRoute(
            destinationID: "article-details",
            title: serviceHeadline,
            subtitle: sourceTitle,
            bodyText: summary,
            accentLabel: translationLabel
        )
    }

    /// Returns a copy with updated runtime-only card UI state.
    func updatingUIState(_ transform: (FeaturedArticleCardUIState) -> FeaturedArticleCardUIState) -> FeaturedArticleCardModel {
        FeaturedArticleCardModel(
            id: id,
            channelID: channelID,
            postedInPrefix: postedInPrefix,
            sourceTitle: sourceTitle,
            brandTitle: brandTitle,
            headline: headline,
            summary: summary,
            metadataLine: metadataLine,
            translationLabel: translationLabel,
            commentCount: commentCount,
            actions: actions,
            uiState: transform(uiState)
        )
    }

    /// Returns a copy with refreshed article content while keeping runtime state local to the screen.
    func updatingContent(
        headline: String? = nil,
        summary: String? = nil,
        metadataLine: String? = nil
    ) -> FeaturedArticleCardModel {
        FeaturedArticleCardModel(
            id: id,
            channelID: channelID,
            postedInPrefix: postedInPrefix,
            sourceTitle: sourceTitle,
            brandTitle: brandTitle,
            headline: headline ?? self.headline,
            summary: summary ?? self.summary,
            metadataLine: metadataLine ?? self.metadataLine,
            translationLabel: translationLabel,
            commentCount: commentCount,
            actions: actions,
            uiState: uiState
        )
    }
}

/// Presentation model for a single action shown under an article.
struct ArticleActionItem: Identifiable, Equatable, Sendable {
    let id: String
    let kind: ArticleActionKind
    let systemName: String
    let title: String
}

/// Semantic action kind shown under a featured article card.
enum ArticleActionKind: String, Codable, Equatable, Sendable {
    case like
    case comments
}

/// Intent emitted from the featured article card UI.
enum FeaturedArticleCardAction: Equatable, Sendable {
    case toggleLike
    case addComment
    case setDisplayMode(FeaturedArticleCardDisplayMode)
    case refreshContent
    case runLongTask
}

/// Runtime-only UI state owned by the screen for a featured article card.
struct FeaturedArticleCardUIState: Equatable, Sendable {
    let isLiked: Bool
    let displayMode: FeaturedArticleCardDisplayMode
    let pendingOperation: FeaturedArticleCardPendingOperation?
    let inlineStatusMessage: String?

    /// When true, the screen should serialize actions for this card and keep the visible
    /// snapshot stable until the current operation completes.
    /// Whether destructive or network-backed card actions should be temporarily disabled.
    var blocksActions: Bool {
        pendingOperation != nil
    }

    /// Default interaction state for cards loaded from persistence or stub content.
    static let idle = FeaturedArticleCardUIState(
        isLiked: false,
        displayMode: .expanded,
        pendingOperation: nil,
        inlineStatusMessage: nil
    )
}

/// Visual layout variant currently used to render the featured article card.
enum FeaturedArticleCardDisplayMode: String, Codable, Equatable, Sendable {
    case expanded
    case compact
}

/// Long-running card operation currently visible in the list.
enum FeaturedArticleCardPendingOperation: Equatable, Sendable {
    case liking
    case addingComment
    case updatingDisplayMode
    case refreshingContent
    case updatingContent

    /// User-facing status text for inline progress rendering.
    var statusText: String {
        switch self {
        case .liking:
            return AppLocalization.text("news.featured.pending.like")
        case .addingComment:
            return AppLocalization.text("news.featured.pending.comment")
        case .updatingDisplayMode:
            return AppLocalization.text("news.featured.pending.displayMode")
        case .refreshingContent:
            return AppLocalization.text("news.featured.pending.refresh")
        case .updatingContent:
            return AppLocalization.text("news.featured.pending.update")
        }
    }
}

/// Presentation model for the discussion preview card.
struct DiscussionCardModel: Identifiable, Equatable, Sendable {
    let id: String
    let channelID: String
    let categoryTitle: String
    let headline: String
    let participants: [DiscussionParticipant]
    let replyCount: Int
    let joinedCount: Int
    let uiState: DiscussionCardUIState

    /// Headline formatted for service consumers that should not receive multiline text.
    var serviceHeadline: String {
        headline.replacingOccurrences(of: "\n", with: " ")
    }

    /// User-facing joined label rendered in the discussion card footer.
    var joinedText: String {
        AppLocalization.text("news.discussion.joinedCountFormat", joinedCount)
    }

    /// Destination payload used by callers that open discussion details.
    var detailRoute: NewsRoute {
        NewsRoute(
            destinationID: "discussion-details",
            title: categoryTitle,
            subtitle: joinedText,
            bodyText: serviceHeadline,
            accentLabel: nil
        )
    }

    /// Returns a copy with updated runtime-only discussion UI state.
    func updatingUIState(_ transform: (DiscussionCardUIState) -> DiscussionCardUIState) -> DiscussionCardModel {
        DiscussionCardModel(
            id: id,
            channelID: channelID,
            categoryTitle: categoryTitle,
            headline: headline,
            participants: participants,
            replyCount: replyCount,
            joinedCount: joinedCount,
            uiState: transform(uiState)
        )
    }

    /// Returns a copy with refreshed discussion content while preserving runtime state.
    func updatingContent(
        headline: String? = nil,
        participants: [DiscussionParticipant]? = nil,
        replyCount: Int? = nil,
        joinedCount: Int? = nil
    ) -> DiscussionCardModel {
        DiscussionCardModel(
            id: id,
            channelID: channelID,
            categoryTitle: categoryTitle,
            headline: headline ?? self.headline,
            participants: participants ?? self.participants,
            replyCount: replyCount ?? self.replyCount,
            joinedCount: joinedCount ?? self.joinedCount,
            uiState: uiState
        )
    }
}

/// Presentation model describing a participant avatar in a discussion preview.
struct DiscussionParticipant: Identifiable, Equatable, Sendable {
    let id: String
    let initials: String
    let isHighlighted: Bool
}

/// Intent emitted from the discussion card UI.
enum DiscussionCardAction: Equatable, Sendable {
    case toggleParticipation
    case addReply
    case setDisplayMode(DiscussionCardDisplayMode)
    case refreshContent
    case runLongTask
}

/// Runtime-only UI state owned by the screen for a discussion card.
struct DiscussionCardUIState: Equatable, Sendable {
    let isParticipating: Bool
    let displayMode: DiscussionCardDisplayMode
    let pendingOperation: DiscussionCardPendingOperation?
    let inlineStatusMessage: String?

    /// When true, the screen should serialize actions for this card and keep the visible
    /// snapshot stable until the current operation completes.
    var blocksActions: Bool {
        pendingOperation != nil
    }

    static let idle = DiscussionCardUIState(
        isParticipating: false,
        displayMode: .expanded,
        pendingOperation: nil,
        inlineStatusMessage: nil
    )
}

/// Visual layout variant currently used to render the discussion card.
enum DiscussionCardDisplayMode: String, Codable, Equatable, Sendable {
    case expanded
    case compact
}

/// Long-running card operation currently visible in a discussion card.
enum DiscussionCardPendingOperation: Equatable, Sendable {
    case togglingParticipation
    case addingReply
    case updatingDisplayMode
    case refreshingContent
    case updatingContent

    var statusText: String {
        switch self {
        case .togglingParticipation:
            return AppLocalization.text("news.discussion.pending.participation")
        case .addingReply:
            return AppLocalization.text("news.discussion.pending.reply")
        case .updatingDisplayMode:
            return AppLocalization.text("news.discussion.pending.displayMode")
        case .refreshingContent:
            return AppLocalization.text("news.discussion.pending.refresh")
        case .updatingContent:
            return AppLocalization.text("news.discussion.pending.update")
        }
    }
}

/// App-level fallback content used while the real feed is still loading or unavailable.
enum NewsFeedFixtures {
    static let fallbackContent = makeFallbackContent(channelID: AppChannel.defaultChannel.id)

    static func makeFallbackContent(channelID: String) -> NewsFeedContent {
        NewsFeedContent(
            cards: [
                .featuredArticle(
                    FeaturedArticleCardModel(
                        id: "featured-article-fallback",
                        channelID: channelID,
                        postedInPrefix: AppLocalization.text("news.fallback.postedInPrefix"),
                        sourceTitle: AppLocalization.text("news.fallback.sourceTitle"),
                        brandTitle: AppLocalization.text("news.fallback.brandTitle"),
                        headline: AppLocalization.text("news.fallback.headline"),
                        summary: AppLocalization.text("news.fallback.summary"),
                        metadataLine: AppLocalization.text("news.fallback.metadataLine"),
                        translationLabel: AppLocalization.text("news.fallback.translationLabel"),
                        commentCount: 48,
                        actions: [
                            ArticleActionItem(
                                id: "like",
                                kind: .like,
                                systemName: "hand.thumbsup.fill",
                                title: AppLocalization.text("news.fallback.action.like")
                            ),
                            ArticleActionItem(
                                id: "comments",
                                kind: .comments,
                                systemName: "bubble.left.fill",
                                title: AppLocalization.text("news.fallback.action.comments")
                            )
                        ],
                        uiState: .idle
                    )
                ),
                .discussion(
                    DiscussionCardModel(
                        id: "discussion-fallback",
                        channelID: channelID,
                        categoryTitle: AppLocalization.text("news.fallback.discussion.category"),
                        headline: AppLocalization.text("news.fallback.discussion.headline"),
                        participants: [
                            DiscussionParticipant(id: "adorlee", initials: "A", isHighlighted: true),
                            DiscussionParticipant(id: "mattis", initials: "M", isHighlighted: false),
                            DiscussionParticipant(id: "sophia", initials: "S", isHighlighted: false)
                        ],
                        replyCount: 12,
                        joinedCount: 12,
                        uiState: .idle
                    )
                )
            ],
            availability: .live
        )
    }
}
