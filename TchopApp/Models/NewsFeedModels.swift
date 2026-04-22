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
    let actions: [ArticleActionItem]

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
}

/// Presentation model for a single action shown under an article.
struct ArticleActionItem: Identifiable, Equatable, Sendable {
    let id: String
    let systemName: String
    let title: String
}

/// Presentation model for the discussion preview card.
struct DiscussionCardModel: Identifiable, Equatable, Sendable {
    let id: String
    let categoryTitle: String
    let headline: String
    let participants: [DiscussionParticipant]
    let joinedText: String

    /// Headline formatted for service consumers that should not receive multiline text.
    var serviceHeadline: String {
        headline.replacingOccurrences(of: "\n", with: " ")
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
}

/// Presentation model describing a participant avatar in a discussion preview.
struct DiscussionParticipant: Identifiable, Equatable, Sendable {
    let id: String
    let initials: String
    let isHighlighted: Bool
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
                        actions: [
                            ArticleActionItem(
                                id: "like",
                                systemName: "hand.thumbsup.fill",
                                title: AppLocalization.text("news.fallback.action.like", fallback: "Like")
                            ),
                            ArticleActionItem(
                                id: "comments",
                                systemName: "bubble.left.fill",
                                title: AppLocalization.text("news.fallback.action.comments", fallback: "48 Comments")
                            )
                        ]
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
                        joinedText: AppLocalization.text("news.fallback.discussion.joinedText", fallback: "+12 joined")
                    )
                )
            ],
            availability: .live
        )
    }()
}
