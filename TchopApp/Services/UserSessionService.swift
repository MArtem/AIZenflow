import Foundation

/// Session service contract used by app-level state.
@MainActor
protocol UserSessionManaging {
    /// Signs in with the provided username and persists the active session marker.
    func signIn(username: String) throws -> AppUser

    /// Restores the active user if a valid persisted session exists.
    func restoreSession() throws -> AppUser?

    /// Clears the persisted active session marker.
    func signOut()
}

/// Default session service backed by `UserDefaults` and the user repository.
@MainActor
final class UserSessionService: UserSessionManaging {
    private enum Keys {
        static let activeUsername = "active_username"
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

    /// Signs in and stores the active username for future restoration.
    func signIn(username: String) throws -> AppUser {
        let user = try userRepository.findOrCreateUser(username: username)
        userDefaults.set(user.username, forKey: Keys.activeUsername)
        return user
    }

    /// Restores the active session and clears stale usernames automatically.
    func restoreSession() throws -> AppUser? {
        guard let username = userDefaults.string(forKey: Keys.activeUsername) else {
            return nil
        }

        guard let user = try userRepository.findUser(username: username) else {
            userDefaults.removeObject(forKey: Keys.activeUsername)
            return nil
        }

        return user
    }

    /// Clears the active persisted session.
    func signOut() {
        userDefaults.removeObject(forKey: Keys.activeUsername)
    }
}
