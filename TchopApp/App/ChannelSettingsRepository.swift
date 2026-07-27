import Foundation

/// User-scoped runtime channel settings resolved immediately after authentication.
struct UserChannelSettingsSnapshot: Equatable, Sendable {
    let availableChannels: [AppChannel]
    let preselectedChannelID: String?
}

/// Development implementation that models backend-delivered channel settings until the real API exists.
@MainActor
struct UserChannelSettingsRepository {
    private static let defaultAvailableChannels: [AppChannel] = [
        .product,
        .community,
        .leadership
    ]

    func loadChannelSettings(for user: AppUser) throws -> UserChannelSettingsSnapshot {
        switch normalizedUsername(user.username) {
        case "eve.holt@reqres.in":
            return UserChannelSettingsSnapshot(
                availableChannels: Self.defaultAvailableChannels,
                preselectedChannelID: AppChannel.product.id
            )
        case "janet.weaver@reqres.in":
            return UserChannelSettingsSnapshot(
                availableChannels: [
                    .community,
                    .product,
                    .leadership
                ],
                preselectedChannelID: AppChannel.community.id
            )
        default:
            return UserChannelSettingsSnapshot(
                availableChannels: Self.defaultAvailableChannels,
                preselectedChannelID: AppChannel.defaultChannel.id
            )
        }
    }

    /// Keeps the development lookup stable regardless of how the username/email was entered.
    private func normalizedUsername(_ username: String) -> String {
        username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
