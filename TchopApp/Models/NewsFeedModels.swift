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

enum ChannelCardMediaContent: Equatable, Sendable {
    case photos(count: Int)
    case video
    case audio
    case pdf

    var kind: ChannelCardMediaKind {
        switch self {
        case .photos:
            return .photo
        case .video:
            return .video
        case .audio:
            return .audio
        case .pdf:
            return .pdf
        }
    }

    var displayTitle: String {
        switch self {
        case let .photos(count):
            return count == 1 ? "1 Photo" : "\(count) Photos"
        case .video:
            return "Video"
        case .audio:
            return "Audio"
        case .pdf:
            return "PDF"
        }
    }
}

enum ChannelCardTextFieldKind: String, CaseIterable, Equatable, Sendable, Identifiable {
    case text
    case headline
    case subheadline
    case source

    var id: String { rawValue }

    var sortOrder: Int {
        switch self {
        case .text:
            return 0
        case .headline:
            return 1
        case .subheadline:
            return 2
        case .source:
            return 3
        }
    }

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
    case photo
    case audio
    case pdf
    case text
    case headline
    case subheadline
    case source

    var id: String { title }

    var title: String {
        switch self {
        case .photoOrVideo: return "Photo or Video"
        case .photo: return "Photo"
        case .audio: return "Audio"
        case .pdf: return "PDF"
        case .text: return "Text"
        case .headline: return "Headline"
        case .subheadline: return "Subheadline"
        case .source: return "Source"
        }
    }
}

struct ChannelCardTextContent: Equatable, Sendable, Identifiable {
    let kind: ChannelCardTextFieldKind
    let text: String

    var id: ChannelCardTextFieldKind { kind }
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
    let media: ChannelCardMediaContent?

    var mediaKind: ChannelCardMediaKind? {
        media?.kind
    }

    var orderedTextContent: [ChannelCardTextContent] {
        ChannelCardTextFieldKind.allCases.compactMap { kind in
            guard let value = textValue(for: kind) else {
                return nil
            }

            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                return nil
            }

            return ChannelCardTextContent(kind: kind, text: trimmed)
        }
    }

    var orderedTextBlocks: [String] {
        orderedTextContent.map(\.text)
    }

    var serviceHeadline: String {
        orderedTextBlocks.first ?? kind.rawValue.capitalized
    }

    private func textValue(for kind: ChannelCardTextFieldKind) -> String? {
        switch kind {
        case .text:
            return text
        case .headline:
            return headline
        case .subheadline:
            return subheadline
        case .source:
            return source
        }
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

/// Stable feed card categories used by cross-card UI logic such as search and create/edit flows.
enum NewsFeedCardKind: String, Equatable, Sendable {
    case text
    case photo
    case video
    case audio
    case pdf
}

/// Search field metadata used to rank card matches without hardcoding search behavior inside each screen.
struct NewsFeedCardSearchField: Equatable, Sendable {
    let priority: Int
    let value: String
}

/// Feed card variants currently supported by the home timeline.
enum NewsFeedCard: Identifiable, Equatable, Sendable {
    case photo(PhotoCardModel)
    case text(TextCardModel)
    case channelCard(ChannelCardContent)

    /// Stable identity forwarded from the underlying card model.
    var id: String {
        switch self {
        case let .photo(card):
            return card.id
        case let .text(card):
            return card.id
        case let .channelCard(card):
            return card.id
        }
    }

    /// Stable card category used by generic feed flows.
    var kind: NewsFeedCardKind {
        switch self {
        case .photo:
            // The current article design is the photo-card baseline in the final card taxonomy.
            return .photo
        case .text:
            // The current discussion design is the text-card baseline in the final card taxonomy.
            return .text
        case let .channelCard(card):
            return card.kind.feedKind
        }
    }

    /// Owning channel for the card.
    var channelID: String {
        switch self {
        case let .photo(card):
            return card.channelID
        case let .text(card):
            return card.channelID
        case let .channelCard(card):
            return card.channelID
        }
    }

    /// Service-facing headline derived from the underlying card content.
    var serviceHeadline: String {
        switch self {
        case let .photo(card):
            return card.serviceHeadline
        case let .text(card):
            return card.serviceHeadline
        case let .channelCard(card):
            return card.serviceHeadline
        }
    }

    /// Prioritized search fields used by channel-local search ranking.
    var searchFields: [NewsFeedCardSearchField] {
        switch self {
        case let .photo(article):
            return [
                NewsFeedCardSearchField(priority: 500, value: article.headline),
                NewsFeedCardSearchField(priority: 400, value: article.summary),
                NewsFeedCardSearchField(priority: 300, value: article.sourceTitle),
                NewsFeedCardSearchField(priority: 250, value: article.brandTitle),
                NewsFeedCardSearchField(priority: 200, value: article.metadataLine),
                NewsFeedCardSearchField(priority: 150, value: article.translationLabel)
            ]
        case let .text(discussion):
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

private extension ChannelCardKind {
    var feedKind: NewsFeedCardKind {
        switch self {
        case .text:
            return .text
        case .photo:
            return .photo
        case .video:
            return .video
        case .audio:
            return .audio
        case .pdf:
            return .pdf
        }
    }
}

/// Presentation model for the featured article card.
struct PhotoCardModel: Identifiable, Equatable, Sendable {
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
    let actions: [PhotoActionItem]
    let uiState: PhotoCardUIState

    /// Headline formatted for service consumers that should not receive multiline text.
    var serviceHeadline: String {
        headline.replacingOccurrences(of: "\n", with: " ")
    }

    /// Destination payload used by callers that open article details.
    var detailRoute: NewsRoute {
        NewsRoute(
            destinationID: "photo-details",
            title: serviceHeadline,
            subtitle: sourceTitle,
            bodyText: summary,
            accentLabel: translationLabel
        )
    }

    /// Returns a copy with updated runtime-only card UI state.
    func updatingUIState(_ transform: (PhotoCardUIState) -> PhotoCardUIState) -> PhotoCardModel {
        PhotoCardModel(
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
    ) -> PhotoCardModel {
        PhotoCardModel(
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
struct PhotoActionItem: Identifiable, Equatable, Sendable {
    let id: String
    let kind: PhotoActionKind
    let systemName: String
    let title: String
}

/// Semantic action kind shown under a featured article card.
enum PhotoActionKind: String, Codable, Equatable, Sendable {
    case like
    case comments
}

/// Intent emitted from the featured article card UI.
enum PhotoCardAction: Equatable, Sendable {
    case toggleLike
    case addComment
    case setDisplayMode(PhotoCardDisplayMode)
    case refreshContent
    case runLongTask
}

/// Runtime-only UI state owned by the screen for a featured article card.
struct PhotoCardUIState: Equatable, Sendable {
    let isLiked: Bool
    let displayMode: PhotoCardDisplayMode
    let pendingOperation: PhotoCardPendingOperation?
    let inlineStatusMessage: String?

    /// When true, the screen should serialize actions for this card and keep the visible
    /// snapshot stable until the current operation completes.
    /// Whether destructive or network-backed card actions should be temporarily disabled.
    var blocksActions: Bool {
        pendingOperation != nil
    }

    /// Default interaction state for cards loaded from persistence or stub content.
    static let idle = PhotoCardUIState(
        isLiked: false,
        displayMode: .expanded,
        pendingOperation: nil,
        inlineStatusMessage: nil
    )
}

/// Visual layout variant currently used to render the featured article card.
enum PhotoCardDisplayMode: String, Codable, Equatable, Sendable {
    case expanded
    case compact
}

/// Long-running card operation currently visible in the list.
enum PhotoCardPendingOperation: Equatable, Sendable {
    case liking
    case addingComment
    case updatingDisplayMode
    case refreshingContent
    case updatingContent

    /// User-facing status text for inline progress rendering.
    var statusText: String {
        switch self {
        case .liking:
            return AppLocalization.text("news.photo.pending.like")
        case .addingComment:
            return AppLocalization.text("news.photo.pending.comment")
        case .updatingDisplayMode:
            return AppLocalization.text("news.photo.pending.displayMode")
        case .refreshingContent:
            return AppLocalization.text("news.photo.pending.refresh")
        case .updatingContent:
            return AppLocalization.text("news.photo.pending.update")
        }
    }
}

/// Presentation model for the discussion preview card.
struct TextCardModel: Identifiable, Equatable, Sendable {
    let id: String
    let channelID: String
    let categoryTitle: String
    let headline: String
    let participants: [TextCardParticipant]
    let replyCount: Int
    let joinedCount: Int
    let uiState: TextCardUIState

    /// Headline formatted for service consumers that should not receive multiline text.
    var serviceHeadline: String {
        headline.replacingOccurrences(of: "\n", with: " ")
    }

    /// User-facing joined label rendered in the discussion card footer.
    var joinedText: String {
        AppLocalization.text("news.text.joinedCountFormat", joinedCount)
    }

    /// Destination payload used by callers that open discussion details.
    var detailRoute: NewsRoute {
        NewsRoute(
            destinationID: "text-details",
            title: categoryTitle,
            subtitle: joinedText,
            bodyText: serviceHeadline,
            accentLabel: nil
        )
    }

    /// Returns a copy with updated runtime-only discussion UI state.
    func updatingUIState(_ transform: (TextCardUIState) -> TextCardUIState) -> TextCardModel {
        TextCardModel(
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
        participants: [TextCardParticipant]? = nil,
        replyCount: Int? = nil,
        joinedCount: Int? = nil
    ) -> TextCardModel {
        TextCardModel(
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
struct TextCardParticipant: Identifiable, Equatable, Sendable {
    let id: String
    let initials: String
    let isHighlighted: Bool
}

/// Intent emitted from the discussion card UI.
enum TextCardAction: Equatable, Sendable {
    case toggleParticipation
    case addReply
    case setDisplayMode(TextCardDisplayMode)
    case refreshContent
    case runLongTask
}

/// Runtime-only UI state owned by the screen for a discussion card.
struct TextCardUIState: Equatable, Sendable {
    let isParticipating: Bool
    let displayMode: TextCardDisplayMode
    let pendingOperation: TextCardPendingOperation?
    let inlineStatusMessage: String?

    /// When true, the screen should serialize actions for this card and keep the visible
    /// snapshot stable until the current operation completes.
    var blocksActions: Bool {
        pendingOperation != nil
    }

    static let idle = TextCardUIState(
        isParticipating: false,
        displayMode: .expanded,
        pendingOperation: nil,
        inlineStatusMessage: nil
    )
}

/// Visual layout variant currently used to render the discussion card.
enum TextCardDisplayMode: String, Codable, Equatable, Sendable {
    case expanded
    case compact
}

/// Long-running card operation currently visible in a discussion card.
enum TextCardPendingOperation: Equatable, Sendable {
    case togglingParticipation
    case addingReply
    case updatingDisplayMode
    case refreshingContent
    case updatingContent

    var statusText: String {
        switch self {
        case .togglingParticipation:
            return AppLocalization.text("news.text.pending.participation")
        case .addingReply:
            return AppLocalization.text("news.text.pending.reply")
        case .updatingDisplayMode:
            return AppLocalization.text("news.text.pending.displayMode")
        case .refreshingContent:
            return AppLocalization.text("news.text.pending.refresh")
        case .updatingContent:
            return AppLocalization.text("news.text.pending.update")
        }
    }
}

/// App-level fallback content used while the real feed is still loading or unavailable.
enum NewsFeedFixtures {
    static let fallbackContent = makeFallbackContent(channelID: AppChannel.defaultChannel.id)

    static func makeFallbackContent(channelID: String) -> NewsFeedContent {
        NewsFeedContent(
            cards: [
                .photo(
                    PhotoCardModel(
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
                            PhotoActionItem(
                                id: "like",
                                kind: .like,
                                systemName: "hand.thumbsup.fill",
                                title: AppLocalization.text("news.fallback.action.like")
                            ),
                            PhotoActionItem(
                                id: "comments",
                                kind: .comments,
                                systemName: "bubble.left.fill",
                                title: AppLocalization.text("news.fallback.action.comments")
                            )
                        ],
                        uiState: .idle
                    )
                ),
                .text(
                    TextCardModel(
                        id: "discussion-fallback",
                        channelID: channelID,
                        categoryTitle: AppLocalization.text("news.fallback.discussion.category"),
                        headline: AppLocalization.text("news.fallback.discussion.headline"),
                        participants: [
                            TextCardParticipant(id: "adorlee", initials: "A", isHighlighted: true),
                            TextCardParticipant(id: "mattis", initials: "M", isHighlighted: false),
                            TextCardParticipant(id: "sophia", initials: "S", isHighlighted: false)
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
