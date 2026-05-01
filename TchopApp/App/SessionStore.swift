import Foundation
import Observation

/// Explicit session lifecycle state shared across the signed-out and authenticated app flows.
enum AppSessionState: Equatable {
    case restoring
    case signedOut
    case authenticated(AppUser)
}

/// App-wide runtime store for the current authenticated user session.
///
/// This store keeps the current session snapshot in memory while persistence remains in the
/// session service, repository, and secure storage layers.
@MainActor
@Observable
final class SessionStore {
    /// Current root session state used by the app root to switch between auth and shell flows.
    private(set) var sessionState: AppSessionState = .restoring

    /// Currently signed-in user, if any.
    var currentUser: AppUser? {
        guard case let .authenticated(user) = sessionState else {
            return nil
        }

        return user
    }

    /// Applies the restoring session state while bootstrap is still resolving persisted credentials.
    func setRestoring() {
        sessionState = .restoring
    }

    /// Applies the signed-out state after logout or when no persisted session exists.
    func setSignedOut() {
        sessionState = .signedOut
    }

    /// Applies an authenticated user snapshot after sign-in, restore, or profile mutation.
    func setAuthenticatedUser(_ user: AppUser) {
        sessionState = .authenticated(user)
    }
}
