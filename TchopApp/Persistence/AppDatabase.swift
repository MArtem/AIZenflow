import CoreData
import Foundation
import SwiftData

/// Runtime identifier for the concrete persistence backend serving the app.
enum AppDatabaseBackendKind: String, Equatable {
    /// SwiftData-backed persistence.
    case swiftData

    /// Core Data-backed persistence.
    case coreData
}

/// Selects which persistence backend should be used at runtime.
enum AppDatabaseBackendSelectionPolicy: Equatable {
    /// Resolves the backend automatically from the current OS capabilities.
    case automatic

    /// Forces SwiftData when it is available.
    case swiftData

    /// Forces Core Data even when SwiftData is available.
    case coreData

    /// Resolves the concrete backend for the current runtime.
    func resolveBackendKind() -> AppDatabaseBackendKind {
        switch self {
        case .automatic:
            if #available(iOS 17, *) {
                return .swiftData
            } else {
                return .coreData
            }
        case .swiftData:
            return .swiftData
        case .coreData:
            return .coreData
        }
    }
}

/// Configuration used when constructing the app persistence layer.
struct AppDatabaseConfiguration: Equatable {
    /// Requested backend selection policy.
    let backendSelectionPolicy: AppDatabaseBackendSelectionPolicy

    /// Indicates whether the underlying store should live in memory only.
    let isStoredInMemoryOnly: Bool

    /// Default persistent configuration used by the production app.
    static let `default` = AppDatabaseConfiguration(
        backendSelectionPolicy: .automatic,
        isStoredInMemoryOnly: false
    )

    /// In-memory configuration suited for tests and previews.
    static let inMemory = AppDatabaseConfiguration(
        backendSelectionPolicy: .automatic,
        isStoredInMemoryOnly: true
    )
}

/// Stored representation of the primary channel header.
struct StoredChannel: Equatable {
    /// Stable channel identifier.
    let id: String

    /// Channel title shown in the header.
    let title: String

    /// Channel subtitle shown under the title.
    let subtitle: String
}

/// Stored representation of a persisted user.
struct StoredUser: Equatable {
    /// Stable user identifier.
    let id: String

    /// Username used for sign-in and session restore.
    let username: String

    /// Timestamp when the user record was created.
    let createdAt: Date
}

/// App-facing persistence adapter contract.
///
/// Repositories depend on this interface instead of binding themselves to
/// framework-specific persistence APIs such as `SwiftData.FetchDescriptor`
/// or `NSManagedObjectContext`.
@MainActor
protocol AppDatabaseManaging {
    /// Concrete backend currently used by the adapter.
    var backendKind: AppDatabaseBackendKind { get }

    /// Fetches the primary channel record if it exists.
    func fetchPrimaryChannel() throws -> StoredChannel?

    /// Returns `true` when at least one channel is already persisted.
    func hasPrimaryChannel() throws -> Bool

    /// Inserts the primary channel into the current transaction scope.
    func insertPrimaryChannel(_ channel: StoredChannel) throws

    /// Fetches a normalized user record by username.
    func fetchUser(username: String) throws -> StoredUser?

    /// Inserts a user into the current transaction scope.
    func insertUser(username: String, createdAt: Date) throws -> StoredUser

    /// Executes a transactional operation and persists it atomically.
    func performTransaction<T>(_ operation: () throws -> T) throws -> T
}

/// Factory responsible for constructing the persistence adapter used by the app.
enum AppDatabase {
    /// Creates the default persistence adapter for the supplied configuration.
    @MainActor
    static func makeDatabaseManager(
        configuration: AppDatabaseConfiguration = .default
    ) -> any AppDatabaseManaging {
        let backendKind = configuration.backendSelectionPolicy.resolveBackendKind()

        switch backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return SwiftDataAppDatabaseAdapter(
                    modelContainer: makeSwiftDataModelContainer(isStoredInMemoryOnly: configuration.isStoredInMemoryOnly)
                )
            }

            return CoreDataAppDatabaseAdapter(
                persistentContainer: makeCoreDataPersistentContainer(isStoredInMemoryOnly: configuration.isStoredInMemoryOnly)
            )
        case .coreData:
            return CoreDataAppDatabaseAdapter(
                persistentContainer: makeCoreDataPersistentContainer(isStoredInMemoryOnly: configuration.isStoredInMemoryOnly)
            )
        }
    }

    /// Builds the SwiftData model container used by the SwiftData adapter.
    @MainActor
    @available(iOS 17, *)
    static func makeSwiftDataModelContainer(isStoredInMemoryOnly: Bool) -> ModelContainer {
        let schema = Schema([
            ChannelRecord.self,
            UserRecord.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create SwiftData model container: \(error)")
        }
    }

    /// Builds the Core Data persistent container used by the Core Data adapter.
    @MainActor
    static func makeCoreDataPersistentContainer(isStoredInMemoryOnly: Bool) -> NSPersistentContainer {
        let container = NSPersistentContainer(
            name: "TchopAppCoreDataStore",
            managedObjectModel: makeCoreDataManagedObjectModel()
        )

        let description = NSPersistentStoreDescription()
        description.type = NSSQLiteStoreType
        description.shouldAddStoreAsynchronously = false

        if isStoredInMemoryOnly {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            description.url = persistentStoreURL()
        }

        container.persistentStoreDescriptions = [description]

        var persistentStoreError: Error?
        container.loadPersistentStores { _, error in
            persistentStoreError = error
        }

        if let persistentStoreError {
            fatalError("Failed to load Core Data persistent store: \(persistentStoreError)")
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
            makeDateAttribute(name: "createdAt")
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
}

/// SwiftData-backed persistence adapter.
@MainActor
@available(iOS 17, *)
final class SwiftDataAppDatabaseAdapter: AppDatabaseManaging {
    /// Shared model container used by the adapter.
    let modelContainer: ModelContainer

    var backendKind: AppDatabaseBackendKind { .swiftData }

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func fetchPrimaryChannel() throws -> StoredChannel? {
        let descriptor = FetchDescriptor<ChannelRecord>()
        return try modelContainer.mainContext.fetch(descriptor).first.map {
            StoredChannel(id: $0.id, title: $0.title, subtitle: $0.subtitle)
        }
    }

    func hasPrimaryChannel() throws -> Bool {
        let descriptor = FetchDescriptor<ChannelRecord>()
        return try modelContainer.mainContext.fetchCount(descriptor) > 0
    }

    func insertPrimaryChannel(_ channel: StoredChannel) throws {
        modelContainer.mainContext.insert(
            ChannelRecord(id: channel.id, title: channel.title, subtitle: channel.subtitle)
        )
    }

    func fetchUser(username: String) throws -> StoredUser? {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedUsername.isEmpty else {
            return nil
        }

        let descriptor = FetchDescriptor<UserRecord>(
            predicate: #Predicate<UserRecord> { record in
                record.username == normalizedUsername
            }
        )

        return try modelContainer.mainContext.fetch(descriptor).first.map {
            StoredUser(id: $0.id, username: $0.username, createdAt: $0.createdAt)
        }
    }

    func insertUser(username: String, createdAt: Date) throws -> StoredUser {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let userRecord = UserRecord(username: normalizedUsername, createdAt: createdAt)
        modelContainer.mainContext.insert(userRecord)
        return StoredUser(
            id: userRecord.id,
            username: userRecord.username,
            createdAt: userRecord.createdAt
        )
    }

    func performTransaction<T>(_ operation: () throws -> T) throws -> T {
        do {
            let result = try operation()
            try modelContainer.mainContext.save()
            return result
        } catch {
            modelContainer.mainContext.rollback()
            throw error
        }
    }
}

/// Core Data-backed persistence adapter.
@MainActor
final class CoreDataAppDatabaseAdapter: AppDatabaseManaging {
    private let persistentContainer: NSPersistentContainer

    var backendKind: AppDatabaseBackendKind { .coreData }

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func fetchPrimaryChannel() throws -> StoredChannel? {
        let request = CoreDataChannelEntity.fetchRequest()
        request.fetchLimit = 1

        let result = try persistentContainer.viewContext.fetch(request).first
        return result.map {
            StoredChannel(id: $0.id, title: $0.title, subtitle: $0.subtitle)
        }
    }

    func hasPrimaryChannel() throws -> Bool {
        let request = CoreDataChannelEntity.fetchRequest()
        return try persistentContainer.viewContext.count(for: request) > 0
    }

    func insertPrimaryChannel(_ channel: StoredChannel) throws {
        let entity = CoreDataChannelEntity(context: persistentContainer.viewContext)
        entity.id = channel.id
        entity.title = channel.title
        entity.subtitle = channel.subtitle
    }

    func fetchUser(username: String) throws -> StoredUser? {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedUsername.isEmpty else {
            return nil
        }

        let request = CoreDataUserEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "username == %@", normalizedUsername)

        let result = try persistentContainer.viewContext.fetch(request).first
        return result.map {
            StoredUser(id: $0.id, username: $0.username, createdAt: $0.createdAt)
        }
    }

    func insertUser(username: String, createdAt: Date) throws -> StoredUser {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let entity = CoreDataUserEntity(context: persistentContainer.viewContext)
        entity.id = UUID().uuidString
        entity.username = normalizedUsername
        entity.createdAt = createdAt

        return StoredUser(
            id: entity.id,
            username: entity.username,
            createdAt: entity.createdAt
        )
    }

    func performTransaction<T>(_ operation: () throws -> T) throws -> T {
        let context = persistentContainer.viewContext

        do {
            let result = try operation()
            if context.hasChanges {
                try context.save()
            }
            return result
        } catch {
            context.rollback()
            throw error
        }
    }
}

/// Core Data entity storing the channel header metadata.
private final class CoreDataChannelEntity: NSManagedObject {
    static let entityName = "CoreDataChannelEntity"

    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var subtitle: String

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<CoreDataChannelEntity> {
        NSFetchRequest<CoreDataChannelEntity>(entityName: entityName)
    }
}

/// Core Data entity storing the app user list.
private final class CoreDataUserEntity: NSManagedObject {
    static let entityName = "CoreDataUserEntity"

    @NSManaged var id: String
    @NSManaged var username: String
    @NSManaged var createdAt: Date

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<CoreDataUserEntity> {
        NSFetchRequest<CoreDataUserEntity>(entityName: entityName)
    }
}
