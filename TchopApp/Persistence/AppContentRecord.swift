import Foundation
import SwiftData

/// Raw feed card kinds supported by the current persistence layer.
enum FeedCardRecordKind: String, Codable, Sendable {
    case photo = "featuredArticle"
    case text = "discussion"
}

/// Persisted action payload stored for featured article cards.
struct FeedCardActionPayload: Codable, Equatable, Sendable {
    let id: String
    let kind: ArticleActionKind
    let systemName: String
    let title: String
}

/// Persisted local state stored for featured article cards.
struct FeedCardArticleStatePayload: Codable, Equatable, Sendable {
    let isLiked: Bool
    let commentCount: Int
    let displayModeRawValue: String
}

/// Persisted local state stored for discussion cards.
struct FeedCardDiscussionStatePayload: Codable, Equatable, Sendable {
    let isParticipating: Bool
    let replyCount: Int
    let joinedCount: Int
    let displayModeRawValue: String
}

/// Persisted participant payload stored for discussion cards.
struct FeedCardParticipantPayload: Codable, Equatable, Sendable {
    let id: String
    let initials: String
    let isHighlighted: Bool
}

/// SwiftData record storing the pinned channel header metadata.
@available(iOS 17, *)
@Model
final class ChannelRecord {
    @Attribute(.unique) var id: String
    var title: String
    var subtitle: String

    /// Creates a new ChannelRecord instance.
    init(
        id: String = AppChannel.defaultChannel.id,
        title: String,
        subtitle: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}

/// SwiftData record storing a persisted home-feed card snapshot.
@available(iOS 17, *)
@Model
final class FeedCardRecord {
    @Attribute(.unique) var id: String
    var channelID: String
    var kindRawValue: String
    var sortOrder: Int
    var remoteUpdatedAt: Date
    var syncedAt: Date
    var publishedAt: Date?

    var postedInPrefix: String?
    var sourceTitle: String?
    var brandTitle: String?
    var headline: String
    var summary: String?
    var metadataLine: String?
    var translationLabel: String?
    var articleActionsData: Data?
    var articleStateData: Data?

    var categoryTitle: String?
    var participantsData: Data?
    var joinedText: String?
    var discussionStateData: Data?

    /// Creates a new FeedCardRecord instance.
    ///
    /// One record stores both the feed ordering metadata and the card-type-specific payload.
    /// This keeps snapshot sync straightforward while the project still supports only a small
    /// set of card kinds.
    init(
        id: String,
        channelID: String,
        kind: FeedCardRecordKind,
        sortOrder: Int,
        remoteUpdatedAt: Date,
        syncedAt: Date,
        publishedAt: Date? = nil,
        postedInPrefix: String? = nil,
        sourceTitle: String? = nil,
        brandTitle: String? = nil,
        headline: String,
        summary: String? = nil,
        metadataLine: String? = nil,
        translationLabel: String? = nil,
        articleActionsData: Data? = nil,
        articleStateData: Data? = nil,
        categoryTitle: String? = nil,
        participantsData: Data? = nil,
        joinedText: String? = nil,
        discussionStateData: Data? = nil
    ) {
        self.id = id
        self.channelID = channelID
        self.kindRawValue = kind.rawValue
        self.sortOrder = sortOrder
        self.remoteUpdatedAt = remoteUpdatedAt
        self.syncedAt = syncedAt
        self.publishedAt = publishedAt
        self.postedInPrefix = postedInPrefix
        self.sourceTitle = sourceTitle
        self.brandTitle = brandTitle
        self.headline = headline
        self.summary = summary
        self.metadataLine = metadataLine
        self.translationLabel = translationLabel
        self.articleActionsData = articleActionsData
        self.articleStateData = articleStateData
        self.categoryTitle = categoryTitle
        self.participantsData = participantsData
        self.joinedText = joinedText
        self.discussionStateData = discussionStateData
    }

    /// Typed feed card kind derived from the stored raw value.
    var kind: FeedCardRecordKind? {
        FeedCardRecordKind(rawValue: kindRawValue)
    }
}

/// SwiftData record storing a user created from the login flow.
@available(iOS 17, *)
@Model
final class UserRecord {
    @Attribute(.unique) var username: String
    var id: String
    var appleUserID: String?
    var createdAt: Date
    var isNavigationStateRestoreEnabled: Bool

    /// Creates a new UserRecord instance.
    init(
        id: String = UUID().uuidString,
        username: String,
        appleUserID: String? = nil,
        createdAt: Date,
        isNavigationStateRestoreEnabled: Bool = true
    ) {
        self.username = username
        self.id = id
        self.appleUserID = appleUserID
        self.createdAt = createdAt
        self.isNavigationStateRestoreEnabled = isNavigationStateRestoreEnabled
    }

    /// Maps the persistence record into the app-level domain user.
    func toDomain() -> AppUser {
        AppUser(
            id: id,
            username: username,
            appleUserID: appleUserID,
            createdAt: createdAt,
            isNavigationStateRestoreEnabled: isNavigationStateRestoreEnabled
        )
    }
}
