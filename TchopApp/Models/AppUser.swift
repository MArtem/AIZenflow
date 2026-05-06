import Foundation

/// Domain model describing a locally persisted user account.
struct AppUser: Equatable, Identifiable {
    /// Stable user identifier.
    let id: String

    /// Display and sign-in name entered on the login screen.
    let username: String

    /// Stable Apple identity identifier when the profile originates from Sign in with Apple.
    let appleUserID: String?

    /// Creation date stored the first time this user signs in.
    let createdAt: Date

    /// Whether navigation state restore is enabled for this user profile.
    let isNavigationStateRestoreEnabled: Bool

    /// Creates a new AppUser instance.
    init(
        id: String,
        username: String,
        appleUserID: String? = nil,
        createdAt: Date,
        isNavigationStateRestoreEnabled: Bool = true
    ) {
        self.id = id
        self.username = username
        self.appleUserID = appleUserID
        self.createdAt = createdAt
        self.isNavigationStateRestoreEnabled = isNavigationStateRestoreEnabled
    }
}
