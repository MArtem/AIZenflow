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
        guard let normalizedUsername = UsernameNormalizer.normalize(username) else {
            return nil
        }

        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return try databaseManager.read(
                    DatabaseReadOperation(swiftData: { context in
                        let descriptor = FetchDescriptor<UserRecord>(
                            predicate: #Predicate<UserRecord> { record in
                                record.username == normalizedUsername
                            }
                        )

                        return try context.fetch(descriptor).first.map(PersistenceUserMapper.map)
                    })
                )
            }

            return try databaseManager.read(
                DatabaseReadOperation(coreData: { context in
                    let request = CoreDataUserEntity.fetchRequest()
                    request.fetchLimit = 1
                    request.predicate = NSPredicate(format: "username == %@", normalizedUsername)
                    return try context.fetch(request).first.map(PersistenceUserMapper.map)
                })
            )
        case .coreData:
            return try databaseManager.read(
                DatabaseReadOperation(coreData: { context in
                    let request = CoreDataUserEntity.fetchRequest()
                    request.fetchLimit = 1
                    request.predicate = NSPredicate(format: "username == %@", normalizedUsername)
                    return try context.fetch(request).first.map(PersistenceUserMapper.map)
                })
            )
        }
    }

    /// Returns the existing user or creates a new one and persists it.
    func findOrCreateUser(username: String) throws -> AppUser {
        guard let normalizedUsername = UsernameNormalizer.normalize(username) else {
            throw UserRepositoryError.invalidUsername
        }

        if let existingUser = try findUser(username: normalizedUsername) {
            return existingUser
        }

        let createdAt = Date()

        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return try databaseManager.write(
                    DatabaseWriteOperation(swiftData: { context in
                        let userRecord = UserRecord(
                            username: normalizedUsername,
                            createdAt: createdAt,
                            isNavigationStateRestoreEnabled: true
                        )
                        context.insert(userRecord)
                        return PersistenceUserMapper.map(userRecord)
                    })
                )
            }

            return try databaseManager.write(
                DatabaseWriteOperation(coreData: { context in
                    let entity = CoreDataUserEntity(context: context)
                    entity.id = UUID().uuidString
                    entity.username = normalizedUsername
                    entity.createdAt = createdAt
                    entity.isNavigationStateRestoreEnabled = true
                    return PersistenceUserMapper.map(entity)
                })
            )
        case .coreData:
            return try databaseManager.write(
                DatabaseWriteOperation(coreData: { context in
                    let entity = CoreDataUserEntity(context: context)
                    entity.id = UUID().uuidString
                    entity.username = normalizedUsername
                    entity.createdAt = createdAt
                    entity.isNavigationStateRestoreEnabled = true
                    return PersistenceUserMapper.map(entity)
                })
            )
        }
    }

    /// Updates restore preference for the provided user identifier.
    func updateNavigationStateRestoreEnabled(
        userID: String,
        isEnabled: Bool
    ) throws -> AppUser {
        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return try databaseManager.write(
                    DatabaseWriteOperation(swiftData: { context in
                        let descriptor = FetchDescriptor<UserRecord>(
                            predicate: #Predicate<UserRecord> { record in
                                record.id == userID
                            }
                        )

                        guard let userRecord = try context.fetch(descriptor).first else {
                            throw UserRepositoryError.userNotFound
                        }

                        userRecord.isNavigationStateRestoreEnabled = isEnabled
                        return PersistenceUserMapper.map(userRecord)
                    })
                )
            }

            return try databaseManager.write(
                DatabaseWriteOperation(coreData: { context in
                    let request = CoreDataUserEntity.fetchRequest()
                    request.fetchLimit = 1
                    request.predicate = NSPredicate(format: "id == %@", userID)

                    guard let entity = try context.fetch(request).first else {
                        throw UserRepositoryError.userNotFound
                    }

                    entity.isNavigationStateRestoreEnabled = isEnabled
                    return PersistenceUserMapper.map(entity)
                })
            )
        case .coreData:
            return try databaseManager.write(
                DatabaseWriteOperation(coreData: { context in
                    let request = CoreDataUserEntity.fetchRequest()
                    request.fetchLimit = 1
                    request.predicate = NSPredicate(format: "id == %@", userID)

                    guard let entity = try context.fetch(request).first else {
                        throw UserRepositoryError.userNotFound
                    }

                    entity.isNavigationStateRestoreEnabled = isEnabled
                    return PersistenceUserMapper.map(entity)
                })
            )
        }
    }
}

private enum UserRepositoryError: Error {
    case userNotFound
    case invalidUsername
}

private enum UsernameNormalizer {
    static func normalize(_ username: String) -> String? {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedUsername.isEmpty else {
            return nil
        }

        return normalizedUsername
    }
}

private enum PersistenceUserMapper {
    static func map(_ record: UserRecord) -> AppUser {
        record.toDomain()
    }

    static func map(_ entity: CoreDataUserEntity) -> AppUser {
        AppUser(
            id: entity.id,
            username: entity.username,
            createdAt: entity.createdAt,
            isNavigationStateRestoreEnabled: entity.isNavigationStateRestoreEnabled
        )
    }
}
