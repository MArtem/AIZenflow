import Foundation
import TchopNetworking

/// DTO returned by the feed API abstraction.
struct FeedResponseDTO: Decodable, Sendable {
    let cards: [FeedCardDTO]
}

/// Card payload variants produced by the feed API.
enum FeedCardDTO: Decodable, Sendable {
    case featuredArticle(FeaturedArticleDTO)
    case discussion(DiscussionDTO)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    private enum CardType: String, Decodable {
        case featuredArticle
        case discussion
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(CardType.self, forKey: .type) {
        case .featuredArticle:
            self = .featuredArticle(try FeaturedArticleDTO(from: decoder))
        case .discussion:
            self = .discussion(try DiscussionDTO(from: decoder))
        }
    }
}

extension FeedCardDTO {
    /// Stable identifier forwarded from the decoded card payload.
    var id: String {
        switch self {
        case let .featuredArticle(article):
            return article.id
        case let .discussion(discussion):
            return discussion.id
        }
    }
}

/// DTO describing the featured article card.
struct FeaturedArticleDTO: Decodable, Sendable {
    let id: String
    let remoteUpdatedAt: Date
    let publishedAt: Date?
    let postedInPrefix: String
    let sourceTitle: String
    let brandTitle: String
    let headline: String
    let summary: String
    let metadataLine: String
    let translationLabel: String
    let localState: FeaturedArticleStateDTO
    let actions: [ArticleActionDTO]
}

/// DTO describing a single article action.
struct ArticleActionDTO: Decodable, Sendable {
    let id: String
    let kind: ArticleActionKind
    let systemName: String
    let title: String
}

/// DTO describing the discussion card.
struct DiscussionDTO: Decodable, Sendable {
    let id: String
    let remoteUpdatedAt: Date
    let publishedAt: Date?
    let categoryTitle: String
    let headline: String
    let participants: [DiscussionParticipantDTO]
    let localState: DiscussionStateDTO
}

/// DTO describing a participant preview inside a discussion card.
struct DiscussionParticipantDTO: Decodable, Sendable {
    let id: String
    let initials: String
    let isHighlighted: Bool
}

/// Persisted article card state returned by the API contract or stub backend.
struct FeaturedArticleStateDTO: Decodable, Sendable {
    let isLiked: Bool
    let commentCount: Int
    let displayMode: FeaturedArticleCardDisplayMode
}

/// Persisted discussion card state returned by the API contract or stub backend.
struct DiscussionStateDTO: Decodable, Sendable {
    let isParticipating: Bool
    let replyCount: Int
    let joinedCount: Int
    let displayMode: DiscussionCardDisplayMode
}

/// Narrow persisted-state context needed by featured article API actions.
struct FeaturedArticleActionContext: Sendable {
    let isLiked: Bool
    let displayMode: FeaturedArticleCardDisplayMode
}

/// Narrow persisted-state context needed by discussion API actions.
struct DiscussionActionContext: Sendable {
    let isParticipating: Bool
    let displayMode: DiscussionCardDisplayMode
}

/// API abstraction used by repositories to fetch home feed content.
protocol FeedAPIManaging: Sendable {
    /// Fetches the current feed payload.
    func fetchFeed() async throws -> FeedResponseDTO

    /// Performs one featured article action and returns the updated card snapshot.
    func performFeaturedArticleAction(
        articleID: String,
        action: FeaturedArticleCardAction,
        context: FeaturedArticleActionContext
    ) async throws -> FeaturedArticleDTO

    /// Performs one discussion action and returns the updated card snapshot.
    func performDiscussionAction(
        discussionID: String,
        action: DiscussionCardAction,
        context: DiscussionActionContext
    ) async throws -> DiscussionDTO
}

/// Stubbed feed API manager used until a real backend contract exists.
///
/// The bundled JSON is treated as the seed contract for fetches, while card actions simulate a
/// successful backend mutation for a single card and let the repository persist the result.
struct StubFeedAPIManager: FeedAPIManaging, Sendable {
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
                stubResponse: {
                    try await FeedAPIStubFactory.makeFeedResponse()
                }
            )
        )
    }

    func performFeaturedArticleAction(
        articleID: String,
        action: FeaturedArticleCardAction,
        context: FeaturedArticleActionContext
    ) async throws -> FeaturedArticleDTO {
        switch action {
        case .toggleLike:
            return try await setFeaturedArticleLike(articleID: articleID, isLiked: !context.isLiked)
        case .addComment:
            return try await addFeaturedArticleComment(articleID: articleID)
        case let .setDisplayMode(displayMode):
            return try await setFeaturedArticleDisplayMode(articleID: articleID, displayMode: displayMode)
        case .refreshContent:
            return try await refreshFeaturedArticle(articleID: articleID)
        case .runLongTask:
            return try await runFeaturedArticleUpdate(articleID: articleID)
        }
    }

    func performDiscussionAction(
        discussionID: String,
        action: DiscussionCardAction,
        context: DiscussionActionContext
    ) async throws -> DiscussionDTO {
        switch action {
        case .toggleParticipation:
            return try await setDiscussionParticipation(
                discussionID: discussionID,
                isParticipating: !context.isParticipating
            )
        case .addReply:
            return try await addDiscussionReply(discussionID: discussionID)
        case let .setDisplayMode(displayMode):
            return try await setDiscussionDisplayMode(discussionID: discussionID, displayMode: displayMode)
        case .refreshContent:
            return try await refreshDiscussion(discussionID: discussionID)
        case .runLongTask:
            return try await runDiscussionUpdate(discussionID: discussionID)
        }
    }

    private func setFeaturedArticleLike(
        articleID: String,
        isLiked: Bool
    ) async throws -> FeaturedArticleDTO {
        try await performFeaturedArticleMutation(path: "feed/articles/\(articleID)/like") { article in
            article.withLocalState(
                FeaturedArticleStateDTO(
                    isLiked: isLiked,
                    commentCount: article.localState.commentCount,
                    displayMode: article.localState.displayMode
                )
            )
        }
    }

    private func addFeaturedArticleComment(articleID: String) async throws -> FeaturedArticleDTO {
        try await performFeaturedArticleMutation(path: "feed/articles/\(articleID)/comments") { article in
            article.withLocalState(
                FeaturedArticleStateDTO(
                    isLiked: article.localState.isLiked,
                    commentCount: article.localState.commentCount + 1,
                    displayMode: article.localState.displayMode
                )
            )
        }
    }

    private func setFeaturedArticleDisplayMode(
        articleID: String,
        displayMode: FeaturedArticleCardDisplayMode
    ) async throws -> FeaturedArticleDTO {
        try await performFeaturedArticleMutation(path: "feed/articles/\(articleID)/display-mode") { article in
            article.withLocalState(
                FeaturedArticleStateDTO(
                    isLiked: article.localState.isLiked,
                    commentCount: article.localState.commentCount,
                    displayMode: displayMode
                )
            )
        }
    }

    private func refreshFeaturedArticle(articleID: String) async throws -> FeaturedArticleDTO {
        // Refresh-like actions mutate content fields rather than local interaction state to mimic a
        // backend returning a rebuilt card snapshot.
        try await performFeaturedArticleMutation(path: "feed/articles/\(articleID)/refresh") { article in
            article.withContent(
                metadataLine: "refreshed just now"
            )
        }
    }

    private func runFeaturedArticleUpdate(articleID: String) async throws -> FeaturedArticleDTO {
        try await performFeaturedArticleMutation(path: "feed/articles/\(articleID)/update") { article in
            article.withContent(
                headline: "Updated article version ready for review",
                summary: "This card now shows a rebuilt content snapshot produced by the stub API to simulate a long-running backend article update finishing inside the feed.",
                metadataLine: "system update completed just now"
            )
        }
    }

    private func setDiscussionParticipation(
        discussionID: String,
        isParticipating: Bool
    ) async throws -> DiscussionDTO {
        try await performDiscussionMutation(path: "feed/discussions/\(discussionID)/participation") { discussion in
            let joinedDelta = isParticipating == discussion.localState.isParticipating ? 0 : (isParticipating ? 1 : -1)
            return discussion.withLocalState(
                DiscussionStateDTO(
                    isParticipating: isParticipating,
                    replyCount: discussion.localState.replyCount,
                    joinedCount: max(0, discussion.localState.joinedCount + joinedDelta),
                    displayMode: discussion.localState.displayMode
                )
            )
        }
    }

    private func addDiscussionReply(discussionID: String) async throws -> DiscussionDTO {
        try await performDiscussionMutation(path: "feed/discussions/\(discussionID)/replies") { discussion in
            discussion.withLocalState(
                DiscussionStateDTO(
                    isParticipating: discussion.localState.isParticipating,
                    replyCount: discussion.localState.replyCount + 1,
                    joinedCount: discussion.localState.joinedCount,
                    displayMode: discussion.localState.displayMode
                )
            )
        }
    }

    private func setDiscussionDisplayMode(
        discussionID: String,
        displayMode: DiscussionCardDisplayMode
    ) async throws -> DiscussionDTO {
        try await performDiscussionMutation(path: "feed/discussions/\(discussionID)/display-mode") { discussion in
            discussion.withLocalState(
                DiscussionStateDTO(
                    isParticipating: discussion.localState.isParticipating,
                    replyCount: discussion.localState.replyCount,
                    joinedCount: discussion.localState.joinedCount,
                    displayMode: displayMode
                )
            )
        }
    }

    private func refreshDiscussion(discussionID: String) async throws -> DiscussionDTO {
        try await performDiscussionMutation(path: "feed/discussions/\(discussionID)/refresh") { discussion in
            discussion.withContent(
                headline: "Refreshed discussion snapshot with the same thread context"
            )
        }
    }

    private func runDiscussionUpdate(discussionID: String) async throws -> DiscussionDTO {
        try await performDiscussionMutation(path: "feed/discussions/\(discussionID)/update") { discussion in
            discussion.withContent(
                headline: "Updated discussion summary ready for participants",
                participants: Array(discussion.participants.prefix(2)) + [
                    DiscussionParticipantDTO(
                        id: "\(discussion.id)-participant-new",
                        initials: "N",
                        isHighlighted: true
                    )
                ]
            )
        }
    }

    private func performFeaturedArticleMutation(
        path: String,
        transform: @escaping @Sendable (FeaturedArticleDTO) -> FeaturedArticleDTO
    ) async throws -> FeaturedArticleDTO {
        // Even in stub mode this still routes through APIManaging so latency, request handling, and
        // higher-level networking integration are exercised instead of bypassed.
        try await apiManager.perform(
            APIRequest(
                path: path,
                method: .post,
                stubResponse: {
                    // Card actions still start from the current bundled contract because there is
                    // no real backend yet. The repository merges the returned DTO with the latest
                    // persisted card state so local changes remain additive across actions.
                    let response = try await FeedAPIStubFactory.makeFeedResponse()
                    guard let article = FeedAPIStubFactory.featuredArticle(in: response, articleID: path.articleID) else {
                        throw FeedAPIStubError.missingCard
                    }
                    try await Task.sleep(for: .milliseconds(180))
                    try Task.checkCancellation()
                    return transform(article)
                }
            )
        )
    }

    private func performDiscussionMutation(
        path: String,
        transform: @escaping @Sendable (DiscussionDTO) -> DiscussionDTO
    ) async throws -> DiscussionDTO {
        try await apiManager.perform(
            APIRequest(
                path: path,
                method: .post,
                stubResponse: {
                    // See the article mutation note above. The repository owns the persisted
                    // source of truth until these calls are backed by a real service.
                    let response = try await FeedAPIStubFactory.makeFeedResponse()
                    guard let discussion = FeedAPIStubFactory.discussion(in: response, discussionID: path.articleID) else {
                        throw FeedAPIStubError.missingCard
                    }
                    try await Task.sleep(for: .milliseconds(220))
                    try Task.checkCancellation()
                    return transform(discussion)
                }
            )
        )
    }
}

enum FeedAPIStubFactory {
    /// Produces the latest full stub feed contract used by refreshes and initial seeding.
    static func makeFeedResponse() async throws -> FeedResponseDTO {
        try await Task.sleep(for: .milliseconds(120))
        try Task.checkCancellation()
        return try loadFeedResponse()
    }

    /// Loads the bundled JSON feed synchronously for seed paths that run before async refreshes.
    static func loadFeedResponse() throws -> FeedResponseDTO {
        let feedData = try loadStubFeedResponseData()
        return try makeJSONDecoder().decode(FeedResponseDTO.self, from: feedData)
    }

    /// Looks up one article card inside the bundled feed seed.
    static func featuredArticle(
        in response: FeedResponseDTO,
        articleID: String
    ) -> FeaturedArticleDTO? {
        for card in response.cards {
            if case let .featuredArticle(article) = card, article.id == articleID {
                return article
            }
        }

        return nil
    }

    /// Looks up one discussion card inside the bundled feed seed.
    static func discussion(
        in response: FeedResponseDTO,
        discussionID: String
    ) -> DiscussionDTO? {
        for card in response.cards {
            if case let .discussion(discussion) = card, discussion.id == discussionID {
                return discussion
            }
        }

        return nil
    }

    private static func loadStubFeedResponseData() throws -> Data {
        guard
            let responseURL = Bundle.main.url(
                forResource: "StubFeedResponse",
                withExtension: "json",
                subdirectory: "Resources"
            ) ?? Bundle.main.url(forResource: "StubFeedResponse", withExtension: "json")
        else {
            throw FeedAPIStubError.missingStubResource
        }

        return try Data(contentsOf: responseURL)
    }

    private static func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            if let date = makeISO8601DateFormatter(withFractionalSeconds: true).date(from: value) {
                return date
            }

            if let date = makeISO8601DateFormatter(withFractionalSeconds: false).date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported ISO8601 date value: \(value)"
            )
        }
        return decoder
    }

    private static func makeISO8601DateFormatter(withFractionalSeconds: Bool) -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = withFractionalSeconds
            ? [.withInternetDateTime, .withFractionalSeconds]
            : [.withInternetDateTime]
        return formatter
    }
}

private enum FeedAPIStubError: Error {
    case missingStubResource
    case missingCard
}

private extension FeaturedArticleDTO {
    func withLocalState(_ localState: FeaturedArticleStateDTO) -> FeaturedArticleDTO {
        FeaturedArticleDTO(
            id: id,
            remoteUpdatedAt: Date(),
            publishedAt: publishedAt,
            postedInPrefix: postedInPrefix,
            sourceTitle: sourceTitle,
            brandTitle: brandTitle,
            headline: headline,
            summary: summary,
            metadataLine: metadataLine,
            translationLabel: translationLabel,
            localState: localState,
            actions: actions
        )
    }

    func withContent(
        headline: String? = nil,
        summary: String? = nil,
        metadataLine: String? = nil
    ) -> FeaturedArticleDTO {
        FeaturedArticleDTO(
            id: id,
            remoteUpdatedAt: Date(),
            publishedAt: publishedAt,
            postedInPrefix: postedInPrefix,
            sourceTitle: sourceTitle,
            brandTitle: brandTitle,
            headline: headline ?? self.headline,
            summary: summary ?? self.summary,
            metadataLine: metadataLine ?? self.metadataLine,
            translationLabel: translationLabel,
            localState: localState,
            actions: actions
        )
    }
}

private extension DiscussionDTO {
    func withLocalState(_ localState: DiscussionStateDTO) -> DiscussionDTO {
        DiscussionDTO(
            id: id,
            remoteUpdatedAt: Date(),
            publishedAt: publishedAt,
            categoryTitle: categoryTitle,
            headline: headline,
            participants: participants,
            localState: localState
        )
    }

    func withContent(
        headline: String? = nil,
        participants: [DiscussionParticipantDTO]? = nil
    ) -> DiscussionDTO {
        DiscussionDTO(
            id: id,
            remoteUpdatedAt: Date(),
            publishedAt: publishedAt,
            categoryTitle: categoryTitle,
            headline: headline ?? self.headline,
            participants: participants ?? self.participants,
            localState: localState
        )
    }
}

private extension String {
    var articleID: String {
        split(separator: "/").dropLast().last.map(String.init) ?? self
    }
}
