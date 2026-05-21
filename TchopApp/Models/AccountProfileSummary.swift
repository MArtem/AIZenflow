import Foundation

/// App-local presentation summary for the currently signed-in account.
struct AccountProfileSummary: Equatable {
    /// User-facing display name for the current account.
    let displayName: String

    /// Short uppercase initials used in compact shell surfaces.
    let initials: String

    /// Human-readable title for the current sign-in method.
    let providerTitle: String

    /// Short explanation of how this account is backed.
    let providerDescription: String

    /// Lightweight account identifier hint suitable for UI display.
    let accountIDHint: String

    /// Creates a presentation summary from the signed-in app user.
    init(user: AppUser) {
        displayName = user.username
        initials = Self.makeInitials(from: user.username)
        accountIDHint = "...\(String(user.id.suffix(8)))"

        if user.appleUserID != nil {
            providerTitle = AppLocalization.text("profile.provider.apple")
            providerDescription = AppLocalization.text("profile.provider.appleDescription")
        } else {
            providerTitle = AppLocalization.text("profile.provider.device")
            providerDescription = AppLocalization.text("profile.provider.deviceDescription")
        }
    }

    /// Builds short initials from the current display name.
    private static func makeInitials(from displayName: String) -> String {
        let parts = displayName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let value = String(letters)
        return value.isEmpty ? "U" : value.uppercased()
    }
}
