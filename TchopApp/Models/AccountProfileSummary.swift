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
            providerTitle = AppLocalization.text(
                "profile.provider.apple",
                fallback: "Sign in with Apple"
            )
            providerDescription = AppLocalization.text(
                "profile.provider.appleDescription",
                fallback: "This local profile is linked to a stable Apple identity and can be restored through Apple sign-in."
            )
        } else {
            providerTitle = AppLocalization.text(
                "profile.provider.local",
                fallback: "Local account"
            )
            providerDescription = AppLocalization.text(
                "profile.provider.localDescription",
                fallback: "This account currently exists only in local app storage on this device."
            )
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
