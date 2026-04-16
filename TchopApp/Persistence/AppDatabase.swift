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
enum AppDatabase {
    /// Creates the shared database manager used by the application.
    @MainActor
    static func makeDatabaseManager(
        configuration: AppDatabaseConfiguration = .persistent
    ) -> any DatabaseManaging {
        do {
            return try DatabaseServiceFactory.makeDatabaseManager(
                configuration: configuration,
                makeSwiftDataContainer: {
                    try makeSwiftDataModelContainer(isStoredInMemoryOnly: configuration.isStoredInMemoryOnly)
                },
                makeCoreDataContainer: {
                    try makeCoreDataPersistentContainer(isStoredInMemoryOnly: configuration.isStoredInMemoryOnly)
                }
            )
        } catch {
            fatalError("Failed to create database manager: \(error)")
        }
    }

    /// Builds the SwiftData model container used by the SwiftData backend.
    @MainActor
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

    /// Builds the Core Data persistent container used by the Core Data backend.
    @MainActor
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

    private static func persistentStoreURL() -> URL {
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
