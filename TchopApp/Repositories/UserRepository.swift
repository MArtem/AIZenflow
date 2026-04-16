import Foundation
import CoreData
import SwiftData
import TchopDatabase

/// Repository interface for loading and creating locally persisted users.
@MainActor
protocol UserRepository {
    /// Finds an existing user by username after normalization.
    func findUser(username: String) throws -> AppUser?

    /// Finds or creates a user with the provided username.
    func findOrCreateUser(username: String) throws -> AppUser

    /// Updates navigation-state-restore preference for a user profile.
    func updateNavigationStateRestoreEnabled(
        userID: String,
        isEnabled: Bool
    ) throws -> AppUser
}

/// Default user repository backed by the configured app database adapter.
@MainActor
final class DefaultUserRepository: UserRepository {
    private let databaseManager: any DatabaseManaging

    init(databaseManager: any DatabaseManaging) {
        self.databaseManager = databaseManager
    }

    /// Finds a normalized user record in local persistence.
    func findUser(username: String) throws -> AppUser? {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedUsername.isEmpty else {
            return nil
        }

        return try databaseManager.read(
            DatabaseReadOperation(
                swiftData: { context in
                    let descriptor = FetchDescriptor<UserRecord>(
                        predicate: #Predicate<UserRecord> { record in
                            record.username == normalizedUsername
                        }
                    )

                    return try context.fetch(descriptor).first.map { $0.toDomain() }
                },
                coreData: { context in
                    let request = CoreDataUserEntity.fetchRequest()
                    request.fetchLimit = 1
                    request.predicate = NSPredicate(format: "username == %@", normalizedUsername)
                    return try context.fetch(request).first.map {
                        AppUser(
                            id: $0.id,
                            username: $0.username,
                            createdAt: $0.createdAt,
                            isNavigationStateRestoreEnabled: $0.isNavigationStateRestoreEnabled
                        )
                    }
                }
            )
        )
    }

    /// Returns the existing user or creates a new one and persists it.
    func findOrCreateUser(username: String) throws -> AppUser {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existingUser = try findUser(username: normalizedUsername) {
            return existingUser
        }

        let createdAt = Date()

        return try databaseManager.write(
            DatabaseWriteOperation(
                swiftData: { context in
                    let userRecord = UserRecord(
                        username: normalizedUsername,
                        createdAt: createdAt,
                        isNavigationStateRestoreEnabled: true
                    )
                    context.insert(userRecord)
                    return userRecord.toDomain()
                },
                coreData: { context in
                    let entity = CoreDataUserEntity(context: context)
                    entity.id = UUID().uuidString
                    entity.username = normalizedUsername
                    entity.createdAt = createdAt
                    entity.isNavigationStateRestoreEnabled = true

                    return AppUser(
                        id: entity.id,
                        username: entity.username,
                        createdAt: entity.createdAt,
                        isNavigationStateRestoreEnabled: entity.isNavigationStateRestoreEnabled
                    )
                }
            )
        )
    }

    /// Updates restore preference for the provided user identifier.
    func updateNavigationStateRestoreEnabled(
        userID: String,
        isEnabled: Bool
    ) throws -> AppUser {
        try databaseManager.write(
            DatabaseWriteOperation(
                swiftData: { context in
                    let descriptor = FetchDescriptor<UserRecord>(
                        predicate: #Predicate<UserRecord> { record in
                            record.id == userID
                        }
                    )

                    guard let userRecord = try context.fetch(descriptor).first else {
                        throw UserRepositoryError.userNotFound
                    }

                    userRecord.isNavigationStateRestoreEnabled = isEnabled
                    return userRecord.toDomain()
                },
                coreData: { context in
                    let request = CoreDataUserEntity.fetchRequest()
                    request.fetchLimit = 1
                    request.predicate = NSPredicate(format: "id == %@", userID)

                    guard let entity = try context.fetch(request).first else {
                        throw UserRepositoryError.userNotFound
                    }

                    entity.isNavigationStateRestoreEnabled = isEnabled

                    return AppUser(
                        id: entity.id,
                        username: entity.username,
                        createdAt: entity.createdAt,
                        isNavigationStateRestoreEnabled: entity.isNavigationStateRestoreEnabled
                    )
                }
            )
        )
    }
}

private enum UserRepositoryError: Error {
    case userNotFound
}
