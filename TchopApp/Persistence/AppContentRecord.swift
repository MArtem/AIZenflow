import Foundation
import SwiftData

/// SwiftData record storing the pinned channel header metadata.
@available(iOS 17, *)
@Model
final class ChannelRecord {
    @Attribute(.unique) var id: String
    var title: String
    var subtitle: String

    /// Creates a new ChannelRecord instance.
    init(
        id: String = "primary-channel",
        title: String,
        subtitle: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}

/// SwiftData record storing a user created from the login flow.
@available(iOS 17, *)
@Model
final class UserRecord {
    @Attribute(.unique) var username: String
    var id: String
    var createdAt: Date
    var isNavigationStateRestoreEnabled: Bool

    /// Creates a new UserRecord instance.
    init(
        id: String = UUID().uuidString,
        username: String,
        createdAt: Date,
        isNavigationStateRestoreEnabled: Bool = true
    ) {
        self.username = username
        self.id = id
        self.createdAt = createdAt
        self.isNavigationStateRestoreEnabled = isNavigationStateRestoreEnabled
    }

    /// Maps the persistence record into the app-level domain user.
    func toDomain() -> AppUser {
        AppUser(
            id: id,
            username: username,
            createdAt: createdAt,
            isNavigationStateRestoreEnabled: isNavigationStateRestoreEnabled
        )
    }
}
