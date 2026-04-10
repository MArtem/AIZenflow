import Foundation
import SwiftData

/// SwiftData record storing the pinned channel header metadata.
@Model
final class ChannelRecord {
    @Attribute(.unique) var id: String
    var title: String
    var subtitle: String

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
@Model
final class UserRecord {
    @Attribute(.unique) var username: String
    var id: String
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        username: String,
        createdAt: Date
    ) {
        self.username = username
        self.id = id
        self.createdAt = createdAt
    }

    /// Maps the persistence record into the app-level domain user.
    func toDomain() -> AppUser {
        AppUser(
            id: id,
            username: username,
            createdAt: createdAt
        )
    }
}
