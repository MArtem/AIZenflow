import Foundation

/// Origin metadata for the feed content currently shown to the user.
enum NewsFeedAvailability: Equatable, Sendable {
    case live
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
}

/// Feed card variants currently supported by the home timeline.
enum NewsFeedCard: Identifiable, Equatable, Sendable {
    case featuredArticle(FeaturedArticleCardModel)
    case discussion(DiscussionCardModel)

    /// Stable identity forwarded from the underlying card model.
    var id: String {
        switch self {
        case let .featuredArticle(card):
            return card.id
        case let .discussion(card):
            return card.id
        }
    }

    /// Service-facing headline derived from the underlying card content.
    var serviceHeadline: String {
        switch self {
        case let .featuredArticle(card):
            return card.serviceHeadline
        case let .discussion(card):
            return card.serviceHeadline
        }
    }
}

/// Presentation model for the featured article card.
struct FeaturedArticleCardModel: Identifiable, Equatable, Sendable {
    let id: String
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
            return AppLocalization.text("news.featured.pending.like", fallback: "Saving reaction...")
        case .addingComment:
            return AppLocalization.text("news.featured.pending.comment", fallback: "Posting comment...")
        case .updatingDisplayMode:
            return AppLocalization.text("news.featured.pending.displayMode", fallback: "Saving layout...")
        case .refreshingContent:
            return AppLocalization.text("news.featured.pending.refresh", fallback: "Refreshing card...")
        case .updatingContent:
            return AppLocalization.text("news.featured.pending.update", fallback: "Updating article...")
        }
    }
}

/// Presentation model for the discussion preview card.
struct DiscussionCardModel: Identifiable, Equatable, Sendable {
    let id: String
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
        "+\(joinedCount) joined"
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
            return AppLocalization.text("news.discussion.pending.participation", fallback: "Saving participation...")
        case .addingReply:
            return AppLocalization.text("news.discussion.pending.reply", fallback: "Posting reply...")
        case .updatingDisplayMode:
            return AppLocalization.text("news.discussion.pending.displayMode", fallback: "Saving layout...")
        case .refreshingContent:
            return AppLocalization.text("news.discussion.pending.refresh", fallback: "Refreshing discussion...")
        case .updatingContent:
            return AppLocalization.text("news.discussion.pending.update", fallback: "Updating discussion...")
        }
    }
}

/// App-level fallback content used while the real feed is still loading or unavailable.
enum NewsFeedFixtures {
    static let fallbackContent: NewsFeedContent = {
        NewsFeedContent(
            cards: [
                .featuredArticle(
                    FeaturedArticleCardModel(
                        id: "featured-article-fallback",
                        postedInPrefix: AppLocalization.text("news.fallback.postedInPrefix", fallback: "Posted in "),
                        sourceTitle: AppLocalization.text("news.fallback.sourceTitle", fallback: "Our Blog"),
                        brandTitle: AppLocalization.text("news.fallback.brandTitle", fallback: "Tchop"),
                        headline: AppLocalization.text("news.fallback.headline", fallback: "Parrots help others in need, study\nshows for first time"),
                        summary: AppLocalization.text("news.fallback.summary", fallback: "Consectetur adipiscing elit. Eget semper at augue amet, facilisis vulputate nec vitae libero. Id scelerisque vestibulum quis faucibus urna sem..."),
                        metadataLine: AppLocalization.text("news.fallback.metadataLine", fallback: "by Adorlee Querry · two days ago · read time: 2min"),
                        translationLabel: AppLocalization.text("news.fallback.translationLabel", fallback: "See translation"),
                        commentCount: 48,
                        actions: [
                            ArticleActionItem(
                                id: "like",
                                kind: .like,
                                systemName: "hand.thumbsup.fill",
                                title: AppLocalization.text("news.fallback.action.like", fallback: "Like")
                            ),
                            ArticleActionItem(
                                id: "comments",
                                kind: .comments,
                                systemName: "bubble.left.fill",
                                title: AppLocalization.text("news.fallback.action.comments", fallback: "48 Comments")
                            )
                        ],
                        uiState: .idle
                    )
                ),
                .discussion(
                    DiscussionCardModel(
                        id: "discussion-fallback",
                        categoryTitle: AppLocalization.text("news.fallback.discussion.category", fallback: "Discussion"),
                        headline: AppLocalization.text("news.fallback.discussion.headline", fallback: "Mattis duis volutpat tincidunt\nhabitant amet in sagittis odio"),
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
    }()
}
