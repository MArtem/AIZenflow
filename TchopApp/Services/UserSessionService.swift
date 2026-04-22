import Foundation
import TchopAppleAuthentication

/// Session service contract used by app-level state.
@MainActor
protocol UserSessionManaging {
    /// Signs in with the provided username and persists the active session marker.
    func signIn(username: String) throws -> AppUser

    /// Signs in with a normalized Apple identity payload and persists the active session marker.
    func signInWithApple(identity: AppleAuthenticationIdentity) throws -> AppUser

    /// Restores the active user if a valid persisted session exists.
    func restoreSession() throws -> AppUser?

    /// Clears the persisted active session marker.
    func signOut()
}

/// Default session service backed by `UserDefaults` and the user repository.
@MainActor
final class UserSessionService: UserSessionManaging {
    private enum Keys {
        static let activeUserID = "active_user_id"
        static let legacyActiveUsername = "active_username"
    }

    private let userRepository: any UserRepository
    private let userDefaults: UserDefaults

    /// Creates a session service.
    init(
        userRepository: any UserRepository,
        userDefaults: UserDefaults = .standard
    ) {
        self.userRepository = userRepository
        self.userDefaults = userDefaults
    }

    /// Signs in and stores the active user identifier for future restoration.
    func signIn(username: String) throws -> AppUser {
        let user = try userRepository.findOrCreateUser(username: username)
        userDefaults.set(user.id, forKey: Keys.activeUserID)
        return user
    }

    /// Signs in with Apple and stores the active user identifier for future restoration.
    func signInWithApple(identity: AppleAuthenticationIdentity) throws -> AppUser {
        let user = try userRepository.findOrCreateAppleUser(
            appleUserID: identity.userID,
            preferredUsername: identity.preferredUsername
        )
        userDefaults.set(user.id, forKey: Keys.activeUserID)
        return user
    }

    /// Restores the active session and clears stale usernames automatically.
    func restoreSession() throws -> AppUser? {
        guard let userID = try activeUserIDForRestore() else {
            return nil
        }

        guard let user = try userRepository.findUser(id: userID) else {
            userDefaults.removeObject(forKey: Keys.activeUserID)
            return nil
        }

        return user
    }

    /// Clears the active persisted session.
    func signOut() {
        userDefaults.removeObject(forKey: Keys.activeUserID)
        userDefaults.removeObject(forKey: Keys.legacyActiveUsername)
    }

    /// Resolves the current persisted user identifier and upgrades legacy username-based session storage.
    private func activeUserIDForRestore() throws -> String? {
        if let activeUserID = userDefaults.string(forKey: Keys.activeUserID) {
            return activeUserID
        }

        guard let legacyUsername = userDefaults.string(forKey: Keys.legacyActiveUsername) else {
            return nil
        }

        guard let user = try userRepository.findUser(username: legacyUsername) else {
            userDefaults.removeObject(forKey: Keys.legacyActiveUsername)
            return nil
        }

        userDefaults.set(user.id, forKey: Keys.activeUserID)
        userDefaults.removeObject(forKey: Keys.legacyActiveUsername)
        return user.id
    }
}
