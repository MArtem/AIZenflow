import CoreData
import Foundation
import SwiftData
import TchopDatabase

/// App-local alias for the active infrastructure backend kind.
typealias AppDatabaseBackendKind = DatabaseBackendKind

/// App-local alias for infrastructure backend selection policy.
typealias AppDatabaseBackendSelectionPolicy = DatabaseBackendSelectionPolicy

/// App-local alias for infrastructure database configuration.
typealias AppDatabaseConfiguration = DatabaseConfiguration

/// Builds app-specific persistence containers and delegates backend selection to the infrastructure package.
@MainActor
enum AppDatabase {
    private static let databaseResolver: any DatabaseManagerResolving = DatabaseManagerResolver()

    /// Creates the shared database manager used by the application.
    @MainActor
    static func makeDatabaseManager(
        configuration: AppDatabaseConfiguration = .persistent
    ) -> any DatabaseManaging {
        do {
            return try makeDatabaseManagerWithPersistentSelection(configuration: configuration)
        } catch {
            fatalError("Failed to create database manager: \(error)")
        }
    }

    @MainActor
    private static func makeDatabaseManagerWithPersistentSelection(
        configuration: AppDatabaseConfiguration
    ) throws -> any DatabaseManaging {
        if configuration.backendSelectionPolicy == .swiftData {
            if #available(iOS 17, *) {
                let swiftDataManager = try makeSwiftDataManager(configuration: configuration)
                AppDatabaseBackendPreferenceStore.save(.swiftData)
                return swiftDataManager
            }

            throw DatabaseError.backendInitializationFailed(
                "SwiftData backend is unavailable on iOS versions below 17."
            )
        }

        if configuration.backendSelectionPolicy == .coreData {
            let coreDataManager = try makeCoreDataManager(configuration: configuration)
            AppDatabaseBackendPreferenceStore.save(.coreData)
            return coreDataManager
        }

        if #available(iOS 17, *) {
            if let storedBackend = AppDatabaseBackendPreferenceStore.load() {
                switch storedBackend {
                case .swiftData:
                    return try makeSwiftDataManager(configuration: configuration)
                case .coreData:
                    return try migrateCoreDataToSwiftDataAndCreateManager(configuration: configuration)
                }
            }

            if hasLegacyCoreDataStoreOnDisk(configuration: configuration) {
                return try migrateCoreDataToSwiftDataAndCreateManager(configuration: configuration)
            }

            let swiftDataManager = try makeSwiftDataManager(configuration: configuration)
            AppDatabaseBackendPreferenceStore.save(.swiftData)
            return swiftDataManager
        } else {
            let coreDataManager = try makeCoreDataManager(configuration: configuration)
            AppDatabaseBackendPreferenceStore.save(.coreData)
            return coreDataManager
        }
    }

    @MainActor
    @available(iOS 17, *)
    private static func migrateCoreDataToSwiftDataAndCreateManager(
        configuration: AppDatabaseConfiguration
    ) throws -> any DatabaseManaging {
        let coreDataManager = try makeCoreDataManager(configuration: configuration)
        let swiftDataManager = try makeSwiftDataManager(configuration: configuration)

        do {
            try AppDatabaseMigrationCoordinator.migrateCoreDataContent(
                from: coreDataManager,
                to: swiftDataManager
            )
            try AppDatabaseContainerFactory.purgeCoreDataStoreFilesIfNeeded(
                isStoredInMemoryOnly: configuration.isStoredInMemoryOnly
            )
            AppDatabaseBackendPreferenceStore.save(.swiftData)
            return swiftDataManager
        } catch {
            assertionFailure(
                "Core Data -> SwiftData migration failed. Keeping Core Data backend. Error: \(error)"
            )
            AppDatabaseBackendPreferenceStore.save(.coreData)
            return coreDataManager
        }
    }

    @MainActor
    private static func makeCoreDataManager(
        configuration: AppDatabaseConfiguration
    ) throws -> CoreDataDatabaseManager {
        let manager = try databaseResolver.makeDatabaseManager(
            configuration: AppDatabaseConfiguration(
                backendSelectionPolicy: .coreData,
                isStoredInMemoryOnly: configuration.isStoredInMemoryOnly
            ),
            factories: DatabaseManagerFactorySet(makeCoreDataContainer: {
                try AppDatabaseContainerFactory.makeCoreDataPersistentContainer(
                    isStoredInMemoryOnly: configuration.isStoredInMemoryOnly
                )
            })
        )

        guard let coreDataManager = manager as? CoreDataDatabaseManager else {
            throw DatabaseError.backendInitializationFailed(
                "Failed to cast database manager to CoreDataDatabaseManager."
            )
        }

        return coreDataManager
    }

    @MainActor
    @available(iOS 17, *)
    private static func makeSwiftDataManager(
        configuration: AppDatabaseConfiguration
    ) throws -> SwiftDataDatabaseManager {
        let manager = try databaseResolver.makeDatabaseManager(
            configuration: AppDatabaseConfiguration(
                backendSelectionPolicy: .swiftData,
                isStoredInMemoryOnly: configuration.isStoredInMemoryOnly
            ),
            factories: DatabaseManagerFactorySet(
                makeSwiftDataContainer: {
                    try AppDatabaseContainerFactory.makeSwiftDataModelContainer(
                        isStoredInMemoryOnly: configuration.isStoredInMemoryOnly
                    )
                }
            )
        )

        guard let swiftDataManager = manager as? SwiftDataDatabaseManager else {
            throw DatabaseError.backendInitializationFailed(
                "Failed to cast database manager to SwiftDataDatabaseManager."
            )
        }

        return swiftDataManager
    }

    @MainActor
    private static func hasLegacyCoreDataStoreOnDisk(configuration: AppDatabaseConfiguration) -> Bool {
        guard !configuration.isStoredInMemoryOnly else {
            return false
        }

        return FileManager.default.fileExists(
            atPath: AppDatabaseContainerFactory.persistentStoreURL().path
        )
    }
}

private enum AppDatabaseBackendPreferenceStore {
    private static let key = "app_database_selected_backend_kind"

    static func load() -> AppDatabaseBackendKind? {
        guard let rawValue = UserDefaults.standard.string(forKey: key) else {
            return nil
        }

        return AppDatabaseBackendKind(rawValue: rawValue)
    }

    static func save(_ backendKind: AppDatabaseBackendKind) {
        UserDefaults.standard.set(backendKind.rawValue, forKey: key)
    }
}

@MainActor
private enum AppDatabaseMigrationCoordinator {
    private struct MigrationChannelPayload {
        let id: String
        let title: String
        let subtitle: String
    }

    private struct MigrationUserPayload {
        let id: String
        let username: String
        let createdAt: Date
        let isNavigationStateRestoreEnabled: Bool
    }

    private struct CoreDataMigrationPayload {
        let channels: [MigrationChannelPayload]
        let users: [MigrationUserPayload]
    }

    @available(iOS 17, *)
    static func migrateCoreDataContent(
        from coreDataManager: CoreDataDatabaseManager,
        to swiftDataManager: SwiftDataDatabaseManager
    ) throws {
        let payload = try makeMigrationPayload(from: coreDataManager)

        try swiftDataManager.write(
            DatabaseWriteOperation(
                swiftData: { context in
                    try upsertChannels(payload.channels, in: context)
                    try upsertUsers(payload.users, in: context)
                }
            )
        ) as Void
    }

    private static func makeMigrationPayload(
        from coreDataManager: CoreDataDatabaseManager
    ) throws -> CoreDataMigrationPayload {
        try coreDataManager.read(
            DatabaseReadOperation(
                coreData: { context in
                    let channelRequest = CoreDataChannelEntity.fetchRequest()
                    let userRequest = CoreDataUserEntity.fetchRequest()

                    let channels = try context.fetch(channelRequest).map {
                        MigrationChannelPayload(
                            id: $0.id,
                            title: $0.title,
                            subtitle: $0.subtitle
                        )
                    }

                    let users = try context.fetch(userRequest).map {
                        MigrationUserPayload(
                            id: $0.id,
                            username: $0.username,
                            createdAt: $0.createdAt,
                            isNavigationStateRestoreEnabled: $0.isNavigationStateRestoreEnabled
                        )
                    }

                    return CoreDataMigrationPayload(channels: channels, users: users)
                }
            )
        )
    }

    @available(iOS 17, *)
    private static func upsertChannels(
        _ channels: [MigrationChannelPayload],
        in context: ModelContext
    ) throws {
        for channel in channels {
            let descriptor = FetchDescriptor<ChannelRecord>()
            if let existing = try context.fetch(descriptor).first(where: { $0.id == channel.id }) {
                existing.title = channel.title
                existing.subtitle = channel.subtitle
            } else {
                context.insert(
                    ChannelRecord(
                        id: channel.id,
                        title: channel.title,
                        subtitle: channel.subtitle
                    )
                )
            }
        }
    }

    @available(iOS 17, *)
    private static func upsertUsers(
        _ users: [MigrationUserPayload],
        in context: ModelContext
    ) throws {
        for user in users {
            let descriptor = FetchDescriptor<UserRecord>()
            if let existing = try context.fetch(descriptor).first(where: { $0.username == user.username }) {
                existing.id = user.id
                existing.createdAt = user.createdAt
                existing.isNavigationStateRestoreEnabled = user.isNavigationStateRestoreEnabled
            } else {
                context.insert(
                    UserRecord(
                        id: user.id,
                        username: user.username,
                        createdAt: user.createdAt,
                        isNavigationStateRestoreEnabled: user.isNavigationStateRestoreEnabled
                    )
                )
            }
        }
    }
}

@MainActor
private enum AppDatabaseContainerFactory {
    @available(iOS 17, *)
    static func makeSwiftDataModelContainer(isStoredInMemoryOnly: Bool) throws -> ModelContainer {
        let schema = Schema([
            ChannelRecord.self,
            UserRecord.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static func makeCoreDataPersistentContainer(isStoredInMemoryOnly: Bool) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(
            name: "TchopAppCoreDataStore",
            managedObjectModel: makeCoreDataManagedObjectModel()
        )

        let description = NSPersistentStoreDescription()
        description.type = isStoredInMemoryOnly ? NSInMemoryStoreType : NSSQLiteStoreType
        description.shouldAddStoreAsynchronously = false

        if !isStoredInMemoryOnly {
            description.url = persistentStoreURL()
        }

        container.persistentStoreDescriptions = [description]

        var persistentStoreError: Error?
        container.loadPersistentStores { _, error in
            persistentStoreError = error
        }

        if let persistentStoreError {
            throw persistentStoreError
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }

    static func purgeCoreDataStoreFilesIfNeeded(isStoredInMemoryOnly: Bool) throws {
        guard !isStoredInMemoryOnly else {
            return
        }

        let sqliteURL = persistentStoreURL()
        let walURL = sqliteURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        let shmURL = sqliteURL.deletingPathExtension().appendingPathExtension("sqlite-shm")

        let fileManager = FileManager.default
        for fileURL in [sqliteURL, walURL, shmURL] where fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    static func persistentStoreURL() -> URL {
        let applicationSupportDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        do {
            try FileManager.default.createDirectory(
                at: applicationSupportDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            fatalError("Failed to create application support directory: \(error)")
        }

        return applicationSupportDirectory.appendingPathComponent("TchopApp.sqlite")
    }

    private static func makeCoreDataManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [
            makeChannelEntityDescription(),
            makeUserEntityDescription()
        ]
        return model
    }

    private static func makeChannelEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = CoreDataChannelEntity.entityName
        entity.managedObjectClassName = NSStringFromClass(CoreDataChannelEntity.self)
        entity.properties = [
            makeStringAttribute(name: "id"),
            makeStringAttribute(name: "title"),
            makeStringAttribute(name: "subtitle")
        ]
        entity.uniquenessConstraints = [["id"]]
        return entity
    }

    private static func makeUserEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = CoreDataUserEntity.entityName
        entity.managedObjectClassName = NSStringFromClass(CoreDataUserEntity.self)
        entity.properties = [
            makeStringAttribute(name: "id"),
            makeStringAttribute(name: "username"),
            makeDateAttribute(name: "createdAt"),
            makeBoolAttribute(name: "isNavigationStateRestoreEnabled")
        ]
        entity.uniquenessConstraints = [["username"]]
        return entity
    }

    private static func makeStringAttribute(name: String) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        return attribute
    }

    private static func makeDateAttribute(name: String) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .dateAttributeType
        attribute.isOptional = false
        return attribute
    }

    private static func makeBoolAttribute(name: String) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .booleanAttributeType
        attribute.isOptional = false
        attribute.defaultValue = true
        return attribute
    }
}

/// Core Data entity storing the primary channel metadata.
final class CoreDataChannelEntity: NSManagedObject {
    static let entityName = "CoreDataChannelEntity"

    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var subtitle: String

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<CoreDataChannelEntity> {
        NSFetchRequest<CoreDataChannelEntity>(entityName: entityName)
    }
}

/// Core Data entity storing signed-in users.
final class CoreDataUserEntity: NSManagedObject {
    static let entityName = "CoreDataUserEntity"

    @NSManaged var id: String
    @NSManaged var username: String
    @NSManaged var createdAt: Date
    @NSManaged var isNavigationStateRestoreEnabled: Bool

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<CoreDataUserEntity> {
        NSFetchRequest<CoreDataUserEntity>(entityName: entityName)
    }
}
