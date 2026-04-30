import Foundation
import CoreData
import SwiftData
import TchopDatabase

/// Repository interface for loading and creating locally persisted users.
@MainActor
protocol UserRepository {
    /// Finds an existing user by its stable persisted identifier.
    func findUser(id: String) throws -> AppUser?

    /// Finds an existing user by username after normalization.
    func findUser(username: String) throws -> AppUser?

    /// Finds or creates a user with the provided username.
    func findOrCreateUser(username: String) throws -> AppUser

    /// Finds or creates a user associated with a stable Apple identity.
    func findOrCreateAppleUser(
        appleUserID: String,
        preferredUsername: String?
    ) throws -> AppUser

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

    /// Creates a new DefaultUserRepository instance.
    init(databaseManager: any DatabaseManaging) {
        self.databaseManager = databaseManager
    }

    /// Finds a persisted user by stable identifier.
    func findUser(id: String) throws -> AppUser? {
        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return try fetchSwiftDataUser(id: id)
            }

            return try fetchCoreDataUser(id: id)
        case .coreData:
            return try fetchCoreDataUser(id: id)
        }
    }

    /// Finds a normalized user record in local persistence.
    func findUser(username: String) throws -> AppUser? {
        guard let normalizedUsername = UsernameNormalizer.normalize(username) else {
            return nil
        }

        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return try fetchSwiftDataUser(username: normalizedUsername)
            }

            return try fetchCoreDataUser(username: normalizedUsername)
        case .coreData:
            return try fetchCoreDataUser(username: normalizedUsername)
        }
    }

    /// Returns the existing Apple-backed user or creates a new one for the provided Apple identity.
    func findOrCreateAppleUser(
        appleUserID: String,
        preferredUsername: String?
    ) throws -> AppUser {
        if let existingUser = try findUser(appleUserID: appleUserID) {
            return existingUser
        }

        let resolvedUsername = try resolveAvailableUsername(preferredUsername: preferredUsername)
        let createdAt = Date()

        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return try createSwiftDataUser(
                    username: resolvedUsername,
                    appleUserID: appleUserID,
                    createdAt: createdAt
                )
            }

            return try createCoreDataUser(
                username: resolvedUsername,
                appleUserID: appleUserID,
                createdAt: createdAt
            )
        case .coreData:
            return try createCoreDataUser(
                username: resolvedUsername,
                appleUserID: appleUserID,
                createdAt: createdAt
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
                return try createSwiftDataUser(
                    username: normalizedUsername,
                    createdAt: createdAt
                )
            }

            return try createCoreDataUser(
                username: normalizedUsername,
                createdAt: createdAt
            )
        case .coreData:
            return try createCoreDataUser(
                username: normalizedUsername,
                createdAt: createdAt
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
                return try updateSwiftDataRestorePreference(
                    userID: userID,
                    isEnabled: isEnabled
                )
            }

            return try updateCoreDataRestorePreference(
                userID: userID,
                isEnabled: isEnabled
            )
        case .coreData:
            return try updateCoreDataRestorePreference(
                userID: userID,
                isEnabled: isEnabled
            )
        }
    }

    @available(iOS 17, *)
    /// Fetches a user from SwiftData by stable identifier.
    private func fetchSwiftDataUser(id: String) throws -> AppUser? {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                try Self.fetchAllSwiftDataUserRecords(in: context)
                    .first(where: { $0.id == id })
                    .map(PersistenceUserMapper.map)
            })
        )
    }

    /// Fetches a user from Core Data by stable identifier.
    private func fetchCoreDataUser(id: String) throws -> AppUser? {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataUserFetchRequest(
                    predicate: NSPredicate(format: "id == %@", id)
                )
                return try context.fetch(request).first.map(PersistenceUserMapper.map)
            })
        )
    }

    @available(iOS 17, *)
    /// Fetches a user from SwiftData by normalized username.
    private func fetchSwiftDataUser(username: String) throws -> AppUser? {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                try Self.fetchAllSwiftDataUserRecords(in: context)
                    .first(where: { $0.username == username })
                    .map(PersistenceUserMapper.map)
            })
        )
    }

    @available(iOS 17, *)
    /// Fetches a user from SwiftData by stable Apple identity identifier.
    private func fetchSwiftDataUser(appleUserID: String) throws -> AppUser? {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                try Self.fetchAllSwiftDataUserRecords(in: context)
                    .first(where: { $0.appleUserID == appleUserID })
                    .map(PersistenceUserMapper.map)
            })
        )
    }

    /// Fetches a user from Core Data by normalized username.
    private func fetchCoreDataUser(username: String) throws -> AppUser? {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataUserFetchRequest(
                    predicate: NSPredicate(format: "username == %@", username)
                )
                return try context.fetch(request).first.map(PersistenceUserMapper.map)
            })
        )
    }

    /// Fetches a user from Core Data by stable Apple identity identifier.
    private func fetchCoreDataUser(appleUserID: String) throws -> AppUser? {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataUserFetchRequest(
                    predicate: NSPredicate(format: "appleUserID == %@", appleUserID)
                )
                return try context.fetch(request).first.map(PersistenceUserMapper.map)
            })
        )
    }

    @available(iOS 17, *)
    /// Creates a new user in SwiftData.
    private func createSwiftDataUser(
        username: String,
        appleUserID: String? = nil,
        createdAt: Date
    ) throws -> AppUser {
        try databaseManager.write(
            DatabaseWriteOperation(swiftData: { context in
                let userRecord = UserRecord(
                    username: username,
                    appleUserID: appleUserID,
                    createdAt: createdAt,
                    isNavigationStateRestoreEnabled: true
                )
                context.insert(userRecord)
                return PersistenceUserMapper.map(userRecord)
            })
        )
    }

    /// Creates a new user in Core Data.
    private func createCoreDataUser(
        username: String,
        appleUserID: String? = nil,
        createdAt: Date
    ) throws -> AppUser {
        try databaseManager.write(
            DatabaseWriteOperation(coreData: { context in
                let entity = CoreDataUserEntity(context: context)
                entity.id = UUID().uuidString
                entity.username = username
                entity.appleUserID = appleUserID
                entity.createdAt = createdAt
                entity.isNavigationStateRestoreEnabled = true
                return PersistenceUserMapper.map(entity)
            })
        )
    }

    @available(iOS 17, *)
    /// Updates the SwiftData restore-preference flag for an existing user.
    private func updateSwiftDataRestorePreference(
        userID: String,
        isEnabled: Bool
    ) throws -> AppUser {
        try databaseManager.write(
            DatabaseWriteOperation(swiftData: { context in
                guard let userRecord = try Self.fetchAllSwiftDataUserRecords(in: context)
                    .first(where: { $0.id == userID }) else {
                    throw UserRepositoryError.userNotFound
                }

                userRecord.isNavigationStateRestoreEnabled = isEnabled
                return PersistenceUserMapper.map(userRecord)
            })
        )
    }

    /// Updates the Core Data restore-preference flag for an existing user.
    private func updateCoreDataRestorePreference(
        userID: String,
        isEnabled: Bool
    ) throws -> AppUser {
        try databaseManager.write(
            DatabaseWriteOperation(coreData: { context in
                let request = Self.makeCoreDataUserFetchRequest(
                    predicate: NSPredicate(format: "id == %@", userID)
                )

                guard let entity = try context.fetch(request).first else {
                    throw UserRepositoryError.userNotFound
                }

                entity.isNavigationStateRestoreEnabled = isEnabled
                return PersistenceUserMapper.map(entity)
            })
        )
    }

    /// Creates a single-record Core Data fetch request with a supplied predicate.
    private static func makeCoreDataUserFetchRequest(
        predicate: NSPredicate
    ) -> NSFetchRequest<CoreDataUserEntity> {
        let request = CoreDataUserEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = predicate
        return request
    }

    @available(iOS 17, *)
    /// Fetches the full local SwiftData user set for small-store repository lookups.
    ///
    /// The local user table is intentionally tiny, so an in-memory filter is acceptable here.
    /// This also avoids Swift 6 strict-concurrency warnings caused by `#Predicate` on mutable
    /// reference-model key paths for `UserRecord`.
    private static func fetchAllSwiftDataUserRecords(
        in context: ModelContext
    ) throws -> [UserRecord] {
        try context.fetch(FetchDescriptor<UserRecord>())
    }

    /// Finds an existing user by Apple identity on the active persistence backend.
    private func findUser(appleUserID: String) throws -> AppUser? {
        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return try fetchSwiftDataUser(appleUserID: appleUserID)
            }

            return try fetchCoreDataUser(appleUserID: appleUserID)
        case .coreData:
            return try fetchCoreDataUser(appleUserID: appleUserID)
        }
    }

    /// Resolves a unique username for a new Apple-backed local profile.
    private func resolveAvailableUsername(
        preferredUsername: String?
    ) throws -> String {
        let baseUsername = UsernameNormalizer.normalize(preferredUsername ?? "")
            ?? AppLocalization.text("login.apple.defaultUsername")

        if try findUser(username: baseUsername) == nil {
            return baseUsername
        }

        for suffix in 2...999 {
            let candidate = "\(baseUsername) \(suffix)"
            if try findUser(username: candidate) == nil {
                return candidate
            }
        }

        throw UserRepositoryError.unableToResolveUniqueUsername
    }
}

enum UserRepositoryError: Error {
    case userNotFound
    case invalidUsername
    case unableToResolveUniqueUsername
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
    @available(iOS 17, *)
    static func map(_ record: UserRecord) -> AppUser {
        record.toDomain()
    }

    static func map(_ entity: CoreDataUserEntity) -> AppUser {
        AppUser(
            id: entity.id,
            username: entity.username,
            appleUserID: entity.appleUserID,
            createdAt: entity.createdAt,
            isNavigationStateRestoreEnabled: entity.isNavigationStateRestoreEnabled
        )
    }
}
