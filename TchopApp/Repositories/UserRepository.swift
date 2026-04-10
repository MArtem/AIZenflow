import Foundation

/// Repository interface for loading and creating locally persisted users.
@MainActor
protocol UserRepository {
    /// Finds an existing user by username after normalization.
    func findUser(username: String) throws -> AppUser?

    /// Finds or creates a user with the provided username.
    func findOrCreateUser(username: String) throws -> AppUser
}

/// Default user repository backed by the configured app database adapter.
@MainActor
final class DefaultUserRepository: UserRepository {
    private let databaseManager: any AppDatabaseManaging

    init(databaseManager: any AppDatabaseManaging) {
        self.databaseManager = databaseManager
    }

    /// Finds a normalized user record in local persistence.
    func findUser(username: String) throws -> AppUser? {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedUsername.isEmpty else {
            return nil
        }

        return try databaseManager.fetchUser(username: normalizedUsername).map {
            AppUser(id: $0.id, username: $0.username, createdAt: $0.createdAt)
        }
    }

    /// Returns the existing user or creates a new one and persists it.
    func findOrCreateUser(username: String) throws -> AppUser {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existingUser = try findUser(username: normalizedUsername) {
            return existingUser
        }

        let storedUser = try databaseManager.performTransaction {
            try databaseManager.insertUser(
                username: normalizedUsername,
                createdAt: Date()
            )
        }

        return AppUser(
            id: storedUser.id,
            username: storedUser.username,
            createdAt: storedUser.createdAt
        )
    }
}
