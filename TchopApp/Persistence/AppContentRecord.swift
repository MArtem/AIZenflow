import Foundation
import SwiftData

/// Sync state for feed cards that are persisted before backend support exists.
enum FeedCardRecordSyncState: String, Codable, Sendable {
    case pendingCreate
    case synced
    case failed
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

/// SwiftData record storing the full feed-card payload created from composer/share/API flows.
@available(iOS 17, *)
@Model
final class FeedCardRecord {
    @Attribute(.unique) var id: String
    var ownerUserID: String?
    var channelID: String
    var kindRawValue: String
    var createdAt: Date
    var payloadData: Data
    var serverID: String?
    var syncStateRawValue: String
    var lastSyncAttemptAt: Date?

    init(
        id: String,
        ownerUserID: String?,
        channelID: String,
        kindRawValue: String,
        createdAt: Date,
        payloadData: Data,
        serverID: String? = nil,
        syncState: FeedCardRecordSyncState = .pendingCreate,
        lastSyncAttemptAt: Date? = nil
    ) {
        self.id = id
        self.ownerUserID = ownerUserID
        self.channelID = channelID
        self.kindRawValue = kindRawValue
        self.createdAt = createdAt
        self.payloadData = payloadData
        self.serverID = serverID
        self.syncStateRawValue = syncState.rawValue
        self.lastSyncAttemptAt = lastSyncAttemptAt
    }

    var syncState: FeedCardRecordSyncState? {
        FeedCardRecordSyncState(rawValue: syncStateRawValue)
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
