import Foundation
import TchopNetworking

/// DTO returned by the feed API abstraction.
struct FeedResponseDTO: Decodable, Sendable {
    let cards: [FeedCardDTO]
}

/// Card payload variants produced by the feed API.
enum FeedCardDTO: Decodable, Sendable {
    case photo(PhotoDTO)
    case text(TextDTO)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    private enum CardType: String, Decodable {
        case photo = "featuredArticle"
        case text = "discussion"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(CardType.self, forKey: .type) {
        case .photo:
            self = .photo(try PhotoDTO(from: decoder))
        case .text:
            self = .text(try TextDTO(from: decoder))
        }
    }
}

extension FeedCardDTO {
    /// Stable identifier forwarded from the decoded card payload.
    var id: String {
        switch self {
        case let .photo(article):
            return article.id
        case let .text(textCard):
            return textCard.id
        }
    }
}

/// DTO describing the featured article card.
struct PhotoDTO: Decodable, Sendable {
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
    let localState: PhotoStateDTO
    let actions: [PhotoActionDTO]
}

/// DTO describing a single article action.
struct PhotoActionDTO: Decodable, Sendable {
    let id: String
    let kind: PhotoActionKind
    let systemName: String
    let title: String
}

/// DTO describing the discussion card.
struct TextDTO: Decodable, Sendable {
    let id: String
    let remoteUpdatedAt: Date
    let publishedAt: Date?
    let categoryTitle: String
    let headline: String
    let participants: [TextCardParticipantDTO]
    let localState: TextStateDTO
}

/// DTO describing a participant preview inside a discussion card.
struct TextCardParticipantDTO: Decodable, Sendable {
    let id: String
    let initials: String
    let isHighlighted: Bool
}

/// Persisted article card state returned by the API contract or stub backend.
struct PhotoStateDTO: Decodable, Sendable {
    let isLiked: Bool
    let commentCount: Int
    let displayMode: PhotoCardDisplayMode
}

/// Persisted discussion card state returned by the API contract or stub backend.
struct TextStateDTO: Decodable, Sendable {
    let isParticipating: Bool
    let replyCount: Int
    let joinedCount: Int
    let displayMode: TextCardDisplayMode
}

/// Narrow persisted-state context needed by featured article API actions.
struct PhotoActionContext: Sendable {
    let isLiked: Bool
    let displayMode: PhotoCardDisplayMode
}

/// Narrow persisted-state context needed by discussion API actions.
struct TextActionContext: Sendable {
    let isParticipating: Bool
    let displayMode: TextCardDisplayMode
}

/// API abstraction used by repositories to fetch home feed content.
protocol FeedAPIManaging: Sendable {
    /// Fetches the current feed payload.
    func fetchFeed(channelID: String) async throws -> FeedResponseDTO

    /// Performs one featured article action and returns the updated card snapshot.
    func performPhotoAction(
        channelID: String,
        articleID: String,
        action: PhotoCardAction,
        context: PhotoActionContext
    ) async throws -> PhotoDTO

    /// Performs one discussion action and returns the updated card snapshot.
    func performTextAction(
        channelID: String,
        discussionID: String,
        action: TextCardAction,
        context: TextActionContext
    ) async throws -> TextDTO
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
    func fetchFeed(channelID: String) async throws -> FeedResponseDTO {
        try await apiManager.perform(
            APIRequest(
                path: "feed/\(channelID)",
                method: .get,
                stubResponse: {
                    try await FeedAPIStubFactory.makeFeedResponse(channelID: channelID)
                }
            )
        )
    }

    func performPhotoAction(
        channelID: String,
        articleID: String,
        action: PhotoCardAction,
        context: PhotoActionContext
    ) async throws -> PhotoDTO {
        switch action {
        case .toggleLike:
            return try await setPhotoLike(
                channelID: channelID,
                articleID: articleID,
                isLiked: !context.isLiked
            )
        case .addComment:
            return try await addPhotoComment(channelID: channelID, articleID: articleID)
        case let .setDisplayMode(displayMode):
            return try await setPhotoDisplayMode(
                channelID: channelID,
                articleID: articleID,
                displayMode: displayMode
            )
        case .refreshContent:
            return try await refreshPhoto(channelID: channelID, articleID: articleID)
        case .runLongTask:
            return try await runPhotoUpdate(channelID: channelID, articleID: articleID)
        }
    }

    func performTextAction(
        channelID: String,
        discussionID: String,
        action: TextCardAction,
        context: TextActionContext
    ) async throws -> TextDTO {
        switch action {
        case .toggleParticipation:
            return try await setTextParticipation(
                channelID: channelID,
                discussionID: discussionID,
                isParticipating: !context.isParticipating
            )
        case .addReply:
            return try await addTextReply(channelID: channelID, discussionID: discussionID)
        case let .setDisplayMode(displayMode):
            return try await setTextDisplayMode(
                channelID: channelID,
                discussionID: discussionID,
                displayMode: displayMode
            )
        case .refreshContent:
            return try await refreshText(channelID: channelID, discussionID: discussionID)
        case .runLongTask:
            return try await runTextUpdate(channelID: channelID, discussionID: discussionID)
        }
    }

    private func setPhotoLike(
        channelID: String,
        articleID: String,
        isLiked: Bool
    ) async throws -> PhotoDTO {
        try await performPhotoMutation(
            channelID: channelID,
            path: "feed/articles/\(articleID)/like"
        ) { article in
            article.withLocalState(
                PhotoStateDTO(
                    isLiked: isLiked,
                    commentCount: article.localState.commentCount,
                    displayMode: article.localState.displayMode
                )
            )
        }
    }

    private func addPhotoComment(
        channelID: String,
        articleID: String
    ) async throws -> PhotoDTO {
        try await performPhotoMutation(
            channelID: channelID,
            path: "feed/articles/\(articleID)/comments"
        ) { article in
            article.withLocalState(
                PhotoStateDTO(
                    isLiked: article.localState.isLiked,
                    commentCount: article.localState.commentCount + 1,
                    displayMode: article.localState.displayMode
                )
            )
        }
    }

    private func setPhotoDisplayMode(
        channelID: String,
        articleID: String,
        displayMode: PhotoCardDisplayMode
    ) async throws -> PhotoDTO {
        try await performPhotoMutation(
            channelID: channelID,
            path: "feed/articles/\(articleID)/display-mode"
        ) { article in
            article.withLocalState(
                PhotoStateDTO(
                    isLiked: article.localState.isLiked,
                    commentCount: article.localState.commentCount,
                    displayMode: displayMode
                )
            )
        }
    }

    private func refreshPhoto(
        channelID: String,
        articleID: String
    ) async throws -> PhotoDTO {
        // Refresh-like actions mutate content fields rather than local interaction state to mimic a
        // backend returning a rebuilt card snapshot.
        try await performPhotoMutation(
            channelID: channelID,
            path: "feed/articles/\(articleID)/refresh"
        ) { article in
            article.withContent(
                metadataLine: "refreshed just now"
            )
        }
    }

    private func runPhotoUpdate(
        channelID: String,
        articleID: String
    ) async throws -> PhotoDTO {
        try await performPhotoMutation(
            channelID: channelID,
            path: "feed/articles/\(articleID)/update"
        ) { article in
            article.withContent(
                headline: "Updated article version ready for review",
                summary: "This card now shows a rebuilt content snapshot produced by the stub API to simulate a long-running backend article update finishing inside the feed.",
                metadataLine: "system update completed just now"
            )
        }
    }

    private func setTextParticipation(
        channelID: String,
        discussionID: String,
        isParticipating: Bool
    ) async throws -> TextDTO {
        try await performTextMutation(
            channelID: channelID,
            path: "feed/discussions/\(discussionID)/participation"
        ) { discussion in
            let joinedDelta = isParticipating == discussion.localState.isParticipating ? 0 : (isParticipating ? 1 : -1)
            return discussion.withLocalState(
                TextStateDTO(
                    isParticipating: isParticipating,
                    replyCount: discussion.localState.replyCount,
                    joinedCount: max(0, discussion.localState.joinedCount + joinedDelta),
                    displayMode: discussion.localState.displayMode
                )
            )
        }
    }

    private func addTextReply(
        channelID: String,
        discussionID: String
    ) async throws -> TextDTO {
        try await performTextMutation(
            channelID: channelID,
            path: "feed/discussions/\(discussionID)/replies"
        ) { discussion in
            discussion.withLocalState(
                TextStateDTO(
                    isParticipating: discussion.localState.isParticipating,
                    replyCount: discussion.localState.replyCount + 1,
                    joinedCount: discussion.localState.joinedCount,
                    displayMode: discussion.localState.displayMode
                )
            )
        }
    }

    private func setTextDisplayMode(
        channelID: String,
        discussionID: String,
        displayMode: TextCardDisplayMode
    ) async throws -> TextDTO {
        try await performTextMutation(
            channelID: channelID,
            path: "feed/discussions/\(discussionID)/display-mode"
        ) { discussion in
            discussion.withLocalState(
                TextStateDTO(
                    isParticipating: discussion.localState.isParticipating,
                    replyCount: discussion.localState.replyCount,
                    joinedCount: discussion.localState.joinedCount,
                    displayMode: displayMode
                )
            )
        }
    }

    private func refreshText(
        channelID: String,
        discussionID: String
    ) async throws -> TextDTO {
        try await performTextMutation(
            channelID: channelID,
            path: "feed/discussions/\(discussionID)/refresh"
        ) { discussion in
            discussion.withContent(
                headline: "Refreshed discussion snapshot with the same thread context"
            )
        }
    }

    private func runTextUpdate(
        channelID: String,
        discussionID: String
    ) async throws -> TextDTO {
        try await performTextMutation(
            channelID: channelID,
            path: "feed/discussions/\(discussionID)/update"
        ) { discussion in
            discussion.withContent(
                headline: "Updated discussion summary ready for participants",
                participants: Array(discussion.participants.prefix(2)) + [
                    TextCardParticipantDTO(
                        id: "\(discussion.id)-participant-new",
                        initials: "N",
                        isHighlighted: true
                    )
                ]
            )
        }
    }

    private func performPhotoMutation(
        channelID: String,
        path: String,
        transform: @escaping @Sendable (PhotoDTO) -> PhotoDTO
    ) async throws -> PhotoDTO {
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
                    let response = try await FeedAPIStubFactory.makeFeedResponse(channelID: channelID)
                    guard let article = FeedAPIStubFactory.photoCard(in: response, articleID: path.articleID) else {
                        throw FeedAPIStubError.missingCard
                    }
                    try await Task.sleep(for: .milliseconds(180))
                    try Task.checkCancellation()
                    return transform(article)
                }
            )
        )
    }

    private func performTextMutation(
        channelID: String,
        path: String,
        transform: @escaping @Sendable (TextDTO) -> TextDTO
    ) async throws -> TextDTO {
        try await apiManager.perform(
            APIRequest(
                path: path,
                method: .post,
                stubResponse: {
                    // See the article mutation note above. The repository owns the persisted
                    // source of truth until these calls are backed by a real service.
                    let response = try await FeedAPIStubFactory.makeFeedResponse(channelID: channelID)
                    guard let discussion = FeedAPIStubFactory.textCard(in: response, discussionID: path.articleID) else {
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
    static func makeFeedResponse(channelID: String) async throws -> FeedResponseDTO {
        try await Task.sleep(for: .milliseconds(120))
        try Task.checkCancellation()
        return try loadFeedResponse(channelID: channelID)
    }

    /// Loads the bundled JSON feed synchronously for seed paths that run before async refreshes.
    static func loadFeedResponse(channelID: String = AppChannel.defaultChannel.id) throws -> FeedResponseDTO {
        let feedData = try loadStubFeedResponseData(channelID: channelID)
        return try makeJSONDecoder().decode(FeedResponseDTO.self, from: feedData)
    }

    /// Looks up one article card inside the bundled feed seed.
    static func photoCard(
        in response: FeedResponseDTO,
        articleID: String
    ) -> PhotoDTO? {
        let unscopedArticleID = unscopedCardID(articleID, kindPrefix: "article-")
        for card in response.cards {
            if case let .photo(article) = card,
               (article.id == articleID || article.id == unscopedArticleID) {
                return article
            }
        }

        return nil
    }

    /// Looks up one discussion card inside the bundled feed seed.
    static func textCard(
        in response: FeedResponseDTO,
        discussionID: String
    ) -> TextDTO? {
        let unscopedDiscussionID = unscopedCardID(discussionID, kindPrefix: "discussion-")
        for card in response.cards {
            if case let .text(discussion) = card,
               (discussion.id == discussionID || discussion.id == unscopedDiscussionID) {
                return discussion
            }
        }

        return nil
    }

    /// Strips a channel-scoped prefix from persisted card ids before matching them against raw stub payload ids.
    private static func unscopedCardID(_ scopedID: String, kindPrefix: String) -> String {
        guard let range = scopedID.range(of: kindPrefix) else {
            return scopedID
        }

        return String(scopedID[range.lowerBound...])
    }

    private static func loadStubFeedResponseData(channelID: String) throws -> Data {
        let resourceName = stubResourceName(for: channelID)
        guard
            let responseURL = Bundle.main.url(
                forResource: resourceName,
                withExtension: "json",
                subdirectory: "Resources"
            ) ?? Bundle.main.url(forResource: resourceName, withExtension: "json")
        else {
            throw FeedAPIStubError.missingStubResource
        }

        return try Data(contentsOf: responseURL)
    }

    private static func stubResourceName(for channelID: String) -> String {
        switch channelID {
        case AppChannel.product.id:
            return "StubFeedResponseProductChannel"
        case AppChannel.community.id:
            return "StubFeedResponseCommunityChannel"
        case AppChannel.leadership.id:
            return "StubFeedResponseLeadershipChannel"
        default:
            return "StubFeedResponse"
        }
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

private extension PhotoDTO {
    func withLocalState(_ localState: PhotoStateDTO) -> PhotoDTO {
        PhotoDTO(
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
    ) -> PhotoDTO {
        PhotoDTO(
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

private extension TextDTO {
    func withLocalState(_ localState: TextStateDTO) -> TextDTO {
        TextDTO(
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
        participants: [TextCardParticipantDTO]? = nil
    ) -> TextDTO {
        TextDTO(
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
