import Foundation

/// Domain model describing a locally persisted user account.
struct AppUser: Equatable, Identifiable {
    /// Stable user identifier.
    let id: String

    /// Display and sign-in name entered on the login screen.
    let username: String

    /// Creation date stored the first time this user signs in.
    let createdAt: Date
}
