import Foundation

/// Root presentation model for the news tab feed.
struct NewsFeedContent: Equatable {
    /// Ordered card list shown in the feed.
    let cards: [NewsFeedCard]
}

/// Feed card variants currently supported by the home timeline.
enum NewsFeedCard: Identifiable, Equatable {
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
}

/// Presentation model for the featured article card.
struct FeaturedArticleCardModel: Identifiable, Equatable {
    let id: String
    let postedInPrefix: String
    let sourceTitle: String
    let brandTitle: String
    let headline: String
    let summary: String
    let metadataLine: String
    let translationLabel: String
    let actions: [ArticleActionItem]
}

/// Presentation model for a single action shown under an article.
struct ArticleActionItem: Identifiable, Equatable {
    let id: String
    let systemName: String
    let title: String
}

/// Presentation model for the discussion preview card.
struct DiscussionCardModel: Identifiable, Equatable {
    let id: String
    let categoryTitle: String
    let headline: String
    let participants: [DiscussionParticipant]
    let joinedText: String
}

/// Presentation model describing a participant avatar in a discussion preview.
struct DiscussionParticipant: Identifiable, Equatable {
    let id: String
    let initials: String
    let isHighlighted: Bool
}
