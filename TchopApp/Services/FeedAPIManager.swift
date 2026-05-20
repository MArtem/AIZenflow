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
        case photo = "photo"
        case text = "text"
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
    let commentCount: Int
    let displayMode: PhotoCardDisplayMode
}

/// Narrow persisted-state context needed by discussion API actions.
struct TextActionContext: Sendable {
    let isParticipating: Bool
    let replyCount: Int
    let joinedCount: Int
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
/// Local-created cards are the only active feed content until a real backend contract replaces
/// this stub. Fetches therefore return an empty payload.
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
                context: context
            )
        case .addComment:
            return try await addPhotoComment(channelID: channelID, articleID: articleID, context: context)
        case let .setDisplayMode(displayMode):
            return try await setPhotoDisplayMode(
                channelID: channelID,
                articleID: articleID,
                context: context,
                displayMode: displayMode
            )
        case .refreshContent:
            return try await refreshPhoto(channelID: channelID, articleID: articleID, context: context)
        case .runLongTask:
            return try await runPhotoUpdate(channelID: channelID, articleID: articleID, context: context)
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
                context: context
            )
        case .addReply:
            return try await addTextReply(channelID: channelID, discussionID: discussionID, context: context)
        case let .setDisplayMode(displayMode):
            return try await setTextDisplayMode(
                channelID: channelID,
                discussionID: discussionID,
                context: context,
                displayMode: displayMode
            )
        case .refreshContent:
            return try await refreshText(channelID: channelID, discussionID: discussionID, context: context)
        case .runLongTask:
            return try await runTextUpdate(channelID: channelID, discussionID: discussionID, context: context)
        }
    }

    private func setPhotoLike(
        channelID: String,
        articleID: String,
        context: PhotoActionContext
    ) async throws -> PhotoDTO {
        try await performPhotoMutation(
            channelID: channelID,
            path: "feed/articles/\(articleID)/like"
        ) { article in
            article.withLocalState(
                PhotoStateDTO(
                    isLiked: !context.isLiked,
                    commentCount: context.commentCount,
                    displayMode: context.displayMode
                )
            )
        }
    }

    private func addPhotoComment(
        channelID: String,
        articleID: String,
        context: PhotoActionContext
    ) async throws -> PhotoDTO {
        try await performPhotoMutation(
            channelID: channelID,
            path: "feed/articles/\(articleID)/comments"
        ) { article in
            article.withLocalState(
                PhotoStateDTO(
                    isLiked: context.isLiked,
                    commentCount: context.commentCount + 1,
                    displayMode: context.displayMode
                )
            )
        }
    }

    private func setPhotoDisplayMode(
        channelID: String,
        articleID: String,
        context: PhotoActionContext,
        displayMode: PhotoCardDisplayMode
    ) async throws -> PhotoDTO {
        try await performPhotoMutation(
            channelID: channelID,
            path: "feed/articles/\(articleID)/display-mode"
        ) { article in
            article.withLocalState(
                PhotoStateDTO(
                    isLiked: context.isLiked,
                    commentCount: context.commentCount,
                    displayMode: displayMode
                )
            )
        }
    }

    private func refreshPhoto(
        channelID: String,
        articleID: String,
        context: PhotoActionContext
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
            .withLocalState(
                PhotoStateDTO(
                    isLiked: context.isLiked,
                    commentCount: context.commentCount,
                    displayMode: context.displayMode
                )
            )
        }
    }

    private func runPhotoUpdate(
        channelID: String,
        articleID: String,
        context: PhotoActionContext
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
            .withLocalState(
                PhotoStateDTO(
                    isLiked: context.isLiked,
                    commentCount: context.commentCount,
                    displayMode: context.displayMode
                )
            )
        }
    }

    private func setTextParticipation(
        channelID: String,
        discussionID: String,
        context: TextActionContext
    ) async throws -> TextDTO {
        try await performTextMutation(
            channelID: channelID,
            path: "feed/discussions/\(discussionID)/participation"
        ) { discussion in
            let nextParticipation = !context.isParticipating
            let joinedDelta = nextParticipation == context.isParticipating ? 0 : (nextParticipation ? 1 : -1)
            return discussion.withLocalState(
                TextStateDTO(
                    isParticipating: nextParticipation,
                    replyCount: context.replyCount,
                    joinedCount: max(0, context.joinedCount + joinedDelta),
                    displayMode: context.displayMode
                )
            )
        }
    }

    private func addTextReply(
        channelID: String,
        discussionID: String,
        context: TextActionContext
    ) async throws -> TextDTO {
        try await performTextMutation(
            channelID: channelID,
            path: "feed/discussions/\(discussionID)/replies"
        ) { discussion in
            discussion.withLocalState(
                TextStateDTO(
                    isParticipating: context.isParticipating,
                    replyCount: context.replyCount + 1,
                    joinedCount: context.joinedCount,
                    displayMode: context.displayMode
                )
            )
        }
    }

    private func setTextDisplayMode(
        channelID: String,
        discussionID: String,
        context: TextActionContext,
        displayMode: TextCardDisplayMode
    ) async throws -> TextDTO {
        try await performTextMutation(
            channelID: channelID,
            path: "feed/discussions/\(discussionID)/display-mode"
        ) { discussion in
            discussion.withLocalState(
                TextStateDTO(
                    isParticipating: context.isParticipating,
                    replyCount: context.replyCount,
                    joinedCount: context.joinedCount,
                    displayMode: displayMode
                )
            )
        }
    }

    private func refreshText(
        channelID: String,
        discussionID: String,
        context: TextActionContext
    ) async throws -> TextDTO {
        try await performTextMutation(
            channelID: channelID,
            path: "feed/discussions/\(discussionID)/refresh"
        ) { discussion in
            discussion.withContent(
                headline: "Refreshed discussion snapshot with the same thread context"
            )
            .withLocalState(
                TextStateDTO(
                    isParticipating: context.isParticipating,
                    replyCount: context.replyCount,
                    joinedCount: context.joinedCount,
                    displayMode: context.displayMode
                )
            )
        }
    }

    private func runTextUpdate(
        channelID: String,
        discussionID: String,
        context: TextActionContext
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
            .withLocalState(
                TextStateDTO(
                    isParticipating: context.isParticipating,
                    replyCount: context.replyCount,
                    joinedCount: context.joinedCount,
                    displayMode: context.displayMode
                )
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
                    guard let article = FeedAPIStubFactory.photoCard(
                        in: response,
                        channelID: channelID,
                        articleID: path.cardID
                    ) else {
                        #if DEBUG
                        assertionFailure(
                            "Stub photo mutation card lookup failed. channelID=\(channelID), path=\(path), cardID=\(path.cardID)"
                        )
                        #endif
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
                    guard let discussion = FeedAPIStubFactory.textCard(
                        in: response,
                        channelID: channelID,
                        discussionID: path.cardID
                    ) else {
                        #if DEBUG
                        assertionFailure(
                            "Stub text mutation card lookup failed. channelID=\(channelID), path=\(path), cardID=\(path.cardID)"
                        )
                        #endif
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
    /// Produces an empty feed response while local-created cards remain the only active runtime content.
    static func makeFeedResponse(channelID: String) async throws -> FeedResponseDTO {
        try await Task.sleep(for: .milliseconds(120))
        try Task.checkCancellation()
        return FeedResponseDTO(cards: [])
    }

    /// Looks up one photo card inside the bundled feed seed.
    static func photoCard(
        in response: FeedResponseDTO,
        channelID: String,
        articleID: String
    ) -> PhotoDTO? {
        let unscopedArticleID = unscopedCardID(articleID, channelID: channelID)
        for card in response.cards {
            if case let .photo(article) = card,
               (article.id == articleID || article.id == unscopedArticleID) {
                return article
            }
        }

        return nil
    }

    /// Looks up one text card inside the bundled feed seed.
    static func textCard(
        in response: FeedResponseDTO,
        channelID: String,
        discussionID: String
    ) -> TextDTO? {
        let unscopedDiscussionID = unscopedCardID(discussionID, channelID: channelID)
        for card in response.cards {
            if case let .text(discussion) = card,
               (discussion.id == discussionID || discussion.id == unscopedDiscussionID) {
                return discussion
            }
        }

        return nil
    }

    /// Strips the channel-scoped `<channelID>-` prefix from persisted card ids.
    private static func unscopedCardID(_ scopedID: String, channelID: String) -> String {
        let scopedPrefix = "\(channelID)-"
        if scopedID.hasPrefix(scopedPrefix) {
            return String(scopedID.dropFirst(scopedPrefix.count))
        }

        guard let separatorIndex = scopedID.firstIndex(of: "-") else {
            return scopedID
        }

        let nextIndex = scopedID.index(after: separatorIndex)
        guard nextIndex < scopedID.endIndex else {
            return scopedID
        }

        return String(scopedID[nextIndex...])
    }

}

private enum FeedAPIStubError: Error {
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
    var cardID: String {
        split(separator: "/").dropLast().last.map(String.init) ?? self
    }
}
