import Foundation
import TchopNetworking

/// DTO returned by the feed API abstraction.
struct FeedResponseDTO {
    let cards: [FeedCardDTO]
}

/// Card payload variants produced by the feed API.
enum FeedCardDTO {
    case featuredArticle(FeaturedArticleDTO)
    case discussion(DiscussionDTO)
}

/// DTO describing the featured article card.
struct FeaturedArticleDTO {
    let id: String
    let postedInPrefix: String
    let sourceTitle: String
    let brandTitle: String
    let headline: String
    let summary: String
    let metadataLine: String
    let translationLabel: String
    let actions: [ArticleActionDTO]
}

/// DTO describing a single article action.
struct ArticleActionDTO {
    let id: String
    let systemName: String
    let title: String
}

/// DTO describing the discussion card.
struct DiscussionDTO {
    let id: String
    let categoryTitle: String
    let headline: String
    let participants: [DiscussionParticipantDTO]
    let joinedText: String
}

/// DTO describing a participant preview inside a discussion card.
struct DiscussionParticipantDTO {
    let id: String
    let initials: String
    let isHighlighted: Bool
}

/// API abstraction used by repositories to fetch home feed content.
protocol FeedAPIManaging {
    /// Fetches the current feed payload.
    func fetchFeed() async throws -> FeedResponseDTO
}

/// Stubbed feed API manager used until a real backend contract exists.
struct StubFeedAPIManager: FeedAPIManaging {
    private let apiManager: any APIManaging

    /// Creates the stub feed API manager with the shared networking client.
    init(apiManager: any APIManaging) {
        self.apiManager = apiManager
    }

    /// Returns a stubbed feed payload through the shared API client.
    func fetchFeed() async throws -> FeedResponseDTO {
        try await apiManager.perform(
            APIRequest(
                path: "feed",
                method: .get,
                stubResponse: FeedAPIStubFactory.makeFeedResponse
            )
        )
    }
}

private enum FeedAPIStubFactory {
    static func makeFeedResponse() async throws -> FeedResponseDTO {
        try await Task.sleep(for: .milliseconds(120))
        try Task.checkCancellation()
        return FeedResponseDTO(cards: [
            .featuredArticle(makeFeaturedArticle()),
            .discussion(makeDiscussion())
        ])
    }

    static func makeFeaturedArticle() -> FeaturedArticleDTO {
        FeaturedArticleDTO(
            id: "article-featured-1",
            postedInPrefix: "Posted in ",
            sourceTitle: "Our Blog",
            brandTitle: "Tchop",
            headline: "Parrots help others in need, study\nshows for first time",
            summary: "Consectetur adipiscing elit. Eget semper at augue amet, facilisis vulputate nec vitae libero. Id scelerisque vestibulum quis faucibus urna sem...",
            metadataLine: "by Adorlee Querry · two days ago · read time: 2min",
            translationLabel: "See translation",
            actions: [
                ArticleActionDTO(
                    id: "article-featured-1-like",
                    systemName: "hand.thumbsup.fill",
                    title: "Like"
                ),
                ArticleActionDTO(
                    id: "article-featured-1-comments",
                    systemName: "bubble.left.fill",
                    title: "48 Comments"
                )
            ]
        )
    }

    static func makeDiscussion() -> DiscussionDTO {
        DiscussionDTO(
            id: "discussion-1",
            categoryTitle: "Discussion",
            headline: "Mattis duis volutpat tincidunt\nhabitant amet in sagittis odio",
            participants: [
                DiscussionParticipantDTO(
                    id: "discussion-1-participant-a",
                    initials: "A",
                    isHighlighted: true
                ),
                DiscussionParticipantDTO(
                    id: "discussion-1-participant-m",
                    initials: "M",
                    isHighlighted: false
                ),
                DiscussionParticipantDTO(
                    id: "discussion-1-participant-s",
                    initials: "S",
                    isHighlighted: false
                )
            ],
            joinedText: "+12 joined"
        )
    }
}
