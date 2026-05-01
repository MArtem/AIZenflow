import Foundation

/// User-scoped runtime channel settings resolved immediately after authentication.
struct UserChannelSettingsSnapshot: Equatable, Sendable {
    let availableChannels: [AppChannel]
    let preselectedChannelID: String?
}

/// Contract for loading the channels/settings snapshot that belongs to the active user.
@MainActor
protocol UserChannelSettingsRepository {
    func loadChannelSettings(for user: AppUser) throws -> UserChannelSettingsSnapshot
}

/// Local stub implementation that models backend-delivered channel settings until the real API exists.
@MainActor
struct LocalUserChannelSettingsRepository: UserChannelSettingsRepository {
    func loadChannelSettings(for user: AppUser) throws -> UserChannelSettingsSnapshot {
        switch normalizedUsername(user.username) {
        case "eve.holt@reqres.in":
            return UserChannelSettingsSnapshot(
                availableChannels: [
                    .primary,
                    .product,
                    .community,
                    .leadership
                ],
                preselectedChannelID: AppChannel.product.id
            )
        case "janet.weaver@reqres.in":
            return UserChannelSettingsSnapshot(
                availableChannels: [
                    .primary,
                    .community,
                    .product,
                    .leadership
                ],
                preselectedChannelID: AppChannel.community.id
            )
        default:
            return UserChannelSettingsSnapshot(
                availableChannels: [
                    .primary,
                    .product,
                    .community,
                    .leadership
                ],
                preselectedChannelID: AppChannel.primary.id
            )
        }
    }

    /// Keeps the local stub lookup stable regardless of how the username/email was entered.
    private func normalizedUsername(_ username: String) -> String {
        username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
