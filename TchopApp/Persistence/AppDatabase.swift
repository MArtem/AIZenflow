import CoreData
import Foundation
import SwiftData
import TchopDatabase

/// Builds app-specific persistence containers and delegates backend selection to the infrastructure package.
@MainActor
enum AppDatabase {
    /// Creates the shared database manager used by the application or throws the underlying bootstrap error.
    @MainActor
    static func makeDatabaseManagerOrThrow(
        configuration: DatabaseConfiguration = .persistent
    ) throws -> any DatabaseManaging {
        /*
         Legacy automatic backend selection, Core Data bootstrap, and Core Data -> SwiftData
         migration path are intentionally kept commented for quick rollback.

         let runtimeContext = try AppDatabaseRuntimeContext.current(for: configuration)
         let resolutionPlan = try AppDatabaseRuntimePolicy.plan(
             for: configuration,
             context: runtimeContext
         )

         return try makeDatabaseManager(
             for: resolutionPlan,
             configuration: configuration
         )
         */

        guard #available(iOS 17, *) else {
            throw DatabaseError.backendInitializationFailed(
                "SwiftData backend is unavailable on iOS versions below 17."
            )
        }

        return try makeSwiftDataManager(configuration: configuration)
    }

    @MainActor
    @available(iOS 17, *)
    private static func makeSwiftDataManager(
        configuration: DatabaseConfiguration
    ) throws -> SwiftDataDatabaseManager {
        let manager = try DatabaseManagerResolver().makeDatabaseManager(
            configuration: DatabaseConfiguration(
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
}

/*
 Legacy automatic backend resolution and Core Data bootstrap are intentionally commented instead
 of deleted so the old path can be restored quickly if product/runtime constraints change.

/// Runtime facts that influence automatic app database backend selection.
struct AppDatabaseRuntimeContext: Equatable {
    let storedBackend: AppDatabaseBackendKind?
    let hasLegacyCoreDataStoreOnDisk: Bool
    let supportsSwiftData: Bool

    /// Builds the current runtime context from app configuration and device capabilities.
    @MainActor
    static func current(for configuration: AppDatabaseConfiguration) throws -> Self {
        Self(
            storedBackend: AppDatabaseBackendPreferenceStore.load(),
            hasLegacyCoreDataStoreOnDisk: try hasLegacyCoreDataStoreOnDisk(
                configuration: configuration
            ),
            supportsSwiftData: AppDatabaseSwiftDataAvailability.current
        )
    }

    /// Checks whether the legacy on-disk Core Data store still exists for the current app runtime.
    @MainActor
    private static func hasLegacyCoreDataStoreOnDisk(
        configuration: AppDatabaseConfiguration
    ) throws -> Bool {
        guard !configuration.isStoredInMemoryOnly else {
            return false
        }

        let storeURL = try AppDatabaseContainerFactory.persistentStoreURL()
        return FileManager.default.fileExists(atPath: storeURL.path)
    }
}

/// App-level resolution plan describing which persistence path should be used.
enum AppDatabaseResolutionPlan: Equatable {
    case useCoreData
    case useSwiftData
    case migrateCoreDataToSwiftData

    /// Returns the backend kind that should be persisted for stable plans.
    var persistedBackendKind: AppDatabaseBackendKind? {
        switch self {
        case .useCoreData:
            return .coreData
        case .useSwiftData:
            return .swiftData
        case .migrateCoreDataToSwiftData:
            return nil
        }
    }
}

/// Thin runtime policy deciding which app persistence path to use before containers are built.
enum AppDatabaseRuntimePolicy {
    /// Resolves the database bootstrap plan from configuration and runtime context.
    ///
    /// The policy prefers SwiftData when possible, but still honors a previously persisted
    /// backend choice so the app can migrate legacy Core Data stores in a controlled way.
    /// Explicit `.swiftData` / `.coreData` launch modes bypass that automatic preference flow
    /// and force a single backend for targeted development runs.
    static func plan(
        for configuration: AppDatabaseConfiguration,
        context: AppDatabaseRuntimeContext
    ) throws -> AppDatabaseResolutionPlan {
        if configuration.backendSelectionPolicy == .swiftData {
            guard context.supportsSwiftData else {
                throw DatabaseError.backendInitializationFailed(
                    "SwiftData backend is unavailable on iOS versions below 17."
                )
            }

            return .useSwiftData
        }

        if configuration.backendSelectionPolicy == .coreData {
            return .useCoreData
        }

        guard context.supportsSwiftData else {
            return .useCoreData
        }

        if let storedBackend = context.storedBackend {
            switch storedBackend {
            case .swiftData:
                return .useSwiftData
            case .coreData:
                return .migrateCoreDataToSwiftData
            }
        }

        if context.hasLegacyCoreDataStoreOnDisk {
            return .migrateCoreDataToSwiftData
        }

        return .useSwiftData
    }
}

/// Centralized SwiftData availability probe used by app-level database policy.
enum AppDatabaseSwiftDataAvailability {
    static var current: Bool {
        if #available(iOS 17, *) {
            return true
        }

        return false
    }
}

private enum AppDatabaseBackendPreferenceStore {
    private static let key = "app_database_selected_backend_kind"

    /// Loads the last backend that completed bootstrap successfully.
    static func load() -> AppDatabaseBackendKind? {
        guard let rawValue = UserDefaults.standard.string(forKey: key) else {
            return nil
        }

        return AppDatabaseBackendKind(rawValue: rawValue)
    }

    /// Persists the stable backend the app should prefer on the next launch.
    static func save(_ backendKind: AppDatabaseBackendKind) {
        UserDefaults.standard.set(backendKind.rawValue, forKey: key)
    }
}

@MainActor
private enum AppDatabaseMigrationCoordinator {
    // Migration uses plain value payloads so the read side and write side stay decoupled from each
    // other's framework-specific record types.
    private struct MigrationChannelPayload {
        let id: String
        let title: String
        let subtitle: String
    }

    private struct MigrationUserPayload {
        let id: String
        let username: String
        let appleUserID: String?
        let createdAt: Date
        let isNavigationStateRestoreEnabled: Bool
    }

    private struct MigrationFeedCardPayload {
        let id: String
        let channelID: String
        let kindRawValue: String
        let sortOrder: Int
        let remoteUpdatedAt: Date
        let syncedAt: Date
        let publishedAt: Date?
        let postedInPrefix: String?
        let sourceTitle: String?
        let brandTitle: String?
        let headline: String
        let summary: String?
        let metadataLine: String?
        let translationLabel: String?
        let articleActionsData: Data?
        let articleStateData: Data?
        let categoryTitle: String?
        let participantsData: Data?
        let joinedText: String?
        let discussionStateData: Data?
    }

    private struct CoreDataMigrationPayload {
        let channels: [MigrationChannelPayload]
        let users: [MigrationUserPayload]
        let feedCards: [MigrationFeedCardPayload]
    }

    @available(iOS 17, *)
    static func migrateCoreDataContent(
        from coreDataManager: CoreDataDatabaseManager,
        to swiftDataManager: SwiftDataDatabaseManager
    ) throws {
        // Read everything from Core Data first, then perform a single SwiftData write pass.
        let payload = try makeMigrationPayload(from: coreDataManager)

        try swiftDataManager.write(
            DatabaseWriteOperation(
                swiftData: { context in
                    try upsertChannels(payload.channels, in: context)
                    try upsertUsers(payload.users, in: context)
                    try upsertFeedCards(payload.feedCards, in: context)
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
                    let feedCardRequest = CoreDataFeedCardEntity.fetchRequest()

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
                            appleUserID: $0.appleUserID,
                            createdAt: $0.createdAt,
                            isNavigationStateRestoreEnabled: $0.isNavigationStateRestoreEnabled
                        )
                    }

                    let feedCards = try context.fetch(feedCardRequest).map {
                        MigrationFeedCardPayload(
                            id: $0.id,
                            channelID: $0.channelID,
                            kindRawValue: $0.kindRawValue,
                            sortOrder: Int($0.sortOrder),
                            remoteUpdatedAt: $0.remoteUpdatedAt,
                            syncedAt: $0.syncedAt,
                            publishedAt: $0.publishedAt,
                            postedInPrefix: $0.postedInPrefix,
                            sourceTitle: $0.sourceTitle,
                            brandTitle: $0.brandTitle,
                            headline: $0.headline,
                            summary: $0.summary,
                            metadataLine: $0.metadataLine,
                            translationLabel: $0.translationLabel,
                            articleActionsData: $0.articleActionsData,
                            articleStateData: $0.articleStateData,
                            categoryTitle: $0.categoryTitle,
                            participantsData: $0.participantsData,
                            joinedText: $0.joinedText,
                            discussionStateData: $0.discussionStateData
                        )
                    }

                    return CoreDataMigrationPayload(
                        channels: channels,
                        users: users,
                        feedCards: feedCards
                    )
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
            if let existing = try context.fetch(descriptor).first(where: {
                if let appleUserID = user.appleUserID {
                    return $0.appleUserID == appleUserID
                }

                return $0.username == user.username
            }) {
                existing.id = user.id
                existing.appleUserID = user.appleUserID
                existing.createdAt = user.createdAt
                existing.isNavigationStateRestoreEnabled = user.isNavigationStateRestoreEnabled
            } else {
                context.insert(
                    UserRecord(
                        id: user.id,
                        username: user.username,
                        appleUserID: user.appleUserID,
                        createdAt: user.createdAt,
                        isNavigationStateRestoreEnabled: user.isNavigationStateRestoreEnabled
                    )
                )
            }
        }
    }

    @available(iOS 17, *)
    private static func upsertFeedCards(
        _ feedCards: [MigrationFeedCardPayload],
        in context: ModelContext
    ) throws {
        // Feed cards are keyed by remote id so cached local interaction state survives the backend
        // switch without changing card identity or ordering.
        for feedCard in feedCards {
            let descriptor = FetchDescriptor<FeedCardRecord>()
            if let existing = try context.fetch(descriptor).first(where: { $0.id == feedCard.id }) {
                existing.channelID = feedCard.channelID
                existing.kindRawValue = feedCard.kindRawValue
                existing.sortOrder = feedCard.sortOrder
                existing.remoteUpdatedAt = feedCard.remoteUpdatedAt
                existing.syncedAt = feedCard.syncedAt
                existing.publishedAt = feedCard.publishedAt
                existing.postedInPrefix = feedCard.postedInPrefix
                existing.sourceTitle = feedCard.sourceTitle
                existing.brandTitle = feedCard.brandTitle
                existing.headline = feedCard.headline
                existing.summary = feedCard.summary
                existing.metadataLine = feedCard.metadataLine
                existing.translationLabel = feedCard.translationLabel
                existing.articleActionsData = feedCard.articleActionsData
                existing.articleStateData = feedCard.articleStateData
                existing.categoryTitle = feedCard.categoryTitle
                existing.participantsData = feedCard.participantsData
                existing.joinedText = feedCard.joinedText
                existing.discussionStateData = feedCard.discussionStateData
            } else {
                context.insert(
                    FeedCardRecord(
                        id: feedCard.id,
                        channelID: feedCard.channelID,
                        kind: FeedCardRecordKind(rawValue: feedCard.kindRawValue) ?? .photo,
                        sortOrder: feedCard.sortOrder,
                        remoteUpdatedAt: feedCard.remoteUpdatedAt,
                        syncedAt: feedCard.syncedAt,
                        publishedAt: feedCard.publishedAt,
                        postedInPrefix: feedCard.postedInPrefix,
                        sourceTitle: feedCard.sourceTitle,
                        brandTitle: feedCard.brandTitle,
                        headline: feedCard.headline,
                        summary: feedCard.summary,
                        metadataLine: feedCard.metadataLine,
                        translationLabel: feedCard.translationLabel,
                        articleActionsData: feedCard.articleActionsData,
                        articleStateData: feedCard.articleStateData,
                        categoryTitle: feedCard.categoryTitle,
                        participantsData: feedCard.participantsData,
                        joinedText: feedCard.joinedText,
                        discussionStateData: feedCard.discussionStateData
                    )
                )
            }
        }
    }
}
*/

@MainActor
private enum AppDatabaseContainerFactory {
    @available(iOS 17, *)
    static func makeSwiftDataModelContainer(isStoredInMemoryOnly: Bool) throws -> ModelContainer {
        // The app keeps its schema local so storage changes remain explicit at the app boundary even
        // though runtime read/write orchestration is delegated to TchopDatabase.
        let schema = Schema([
            ChannelRecord.self,
            UserRecord.self,
            FeedCardRecord.self
        ])

        let configuration: ModelConfiguration
        if isStoredInMemoryOnly {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
        } else {
            configuration = ModelConfiguration(
                "TchopAppSwiftDataStore",
                schema: schema,
                url: try swiftDataPersistentStoreURL()
            )
        }

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static func makeCoreDataPersistentContainer(isStoredInMemoryOnly: Bool) throws -> NSPersistentContainer {
        // Core Data is built programmatically so the legacy fallback backend stays self-contained and
        // does not depend on a separate .xcdatamodel resource.
        let container = NSPersistentContainer(
            name: "TchopAppCoreDataStore",
            managedObjectModel: makeCoreDataManagedObjectModel()
        )

        let description = NSPersistentStoreDescription()
        description.type = isStoredInMemoryOnly ? NSInMemoryStoreType : NSSQLiteStoreType
        description.shouldAddStoreAsynchronously = false

        if !isStoredInMemoryOnly {
            description.url = try persistentStoreURL()
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
        container.viewContext.mergePolicy = NSMergePolicy(
            merge: .mergeByPropertyObjectTrumpMergePolicyType
        )
        return container
    }

    static func purgeCoreDataStoreFilesIfNeeded(isStoredInMemoryOnly: Bool) throws {
        guard !isStoredInMemoryOnly else {
            return
        }

        // Remove the legacy files only after a successful migration to avoid orphaning the app
        // without a usable persistent store on the next launch.
        let sqliteURL = try persistentStoreURL()
        let walURL = sqliteURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        let shmURL = sqliteURL.deletingPathExtension().appendingPathExtension("sqlite-shm")

        let fileManager = FileManager.default
        for fileURL in [sqliteURL, walURL, shmURL] where fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    static func persistentStoreURL() throws -> URL {
        // The app owns the exact store location so bootstrap, migration, and purge logic all target
        // the same files deterministically.
        let applicationSupportDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        try FileManager.default.createDirectory(
            at: applicationSupportDirectory,
            withIntermediateDirectories: true
        )

        return applicationSupportDirectory.appendingPathComponent("TchopApp.sqlite")
    }

    @available(iOS 17, *)
    private static func swiftDataPersistentStoreURL() throws -> URL {
        // SwiftData also uses an app-owned explicit location so schema changes do not depend on
        // opaque framework-generated file placement across refactors.
        let applicationSupportDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        try FileManager.default.createDirectory(
            at: applicationSupportDirectory,
            withIntermediateDirectories: true
        )

        return applicationSupportDirectory.appendingPathComponent("TchopAppSwiftData.store")
    }

    private static func makeCoreDataManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [
            makeChannelEntityDescription(),
            makeUserEntityDescription(),
            makeFeedCardEntityDescription()
        ]
        return model
    }

    /// Defines the legacy Core Data schema for the shell channel metadata.
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

    /// Defines the legacy Core Data schema for signed-in users and shell-level preferences.
    private static func makeUserEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = CoreDataUserEntity.entityName
        entity.managedObjectClassName = NSStringFromClass(CoreDataUserEntity.self)
        entity.properties = [
            makeStringAttribute(name: "id"),
            makeStringAttribute(name: "username"),
            makeStringAttribute(name: "appleUserID", isOptional: true),
            makeDateAttribute(name: "createdAt"),
            makeBoolAttribute(name: "isNavigationStateRestoreEnabled")
        ]
        entity.uniquenessConstraints = [["username"]]
        return entity
    }

    /// Defines the legacy Core Data schema for cached feed cards and their persisted local state.
    private static func makeFeedCardEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = CoreDataFeedCardEntity.entityName
        entity.managedObjectClassName = NSStringFromClass(CoreDataFeedCardEntity.self)
        entity.properties = [
            makeStringAttribute(name: "id"),
            makeStringAttribute(name: "channelID"),
            makeStringAttribute(name: "kindRawValue"),
            makeIntegerAttribute(name: "sortOrder"),
            makeDateAttribute(name: "remoteUpdatedAt"),
            makeDateAttribute(name: "syncedAt"),
            makeDateAttribute(name: "publishedAt", isOptional: true),
            makeStringAttribute(name: "postedInPrefix", isOptional: true),
            makeStringAttribute(name: "sourceTitle", isOptional: true),
            makeStringAttribute(name: "brandTitle", isOptional: true),
            makeStringAttribute(name: "headline"),
            makeStringAttribute(name: "summary", isOptional: true),
            makeStringAttribute(name: "metadataLine", isOptional: true),
            makeStringAttribute(name: "translationLabel", isOptional: true),
            makeBinaryDataAttribute(name: "articleActionsData", isOptional: true),
            makeBinaryDataAttribute(name: "articleStateData", isOptional: true),
            makeStringAttribute(name: "categoryTitle", isOptional: true),
            makeBinaryDataAttribute(name: "participantsData", isOptional: true),
            makeStringAttribute(name: "joinedText", isOptional: true),
            makeBinaryDataAttribute(name: "discussionStateData", isOptional: true)
        ]
        entity.uniquenessConstraints = [["id"]]
        return entity
    }

    private static func makeStringAttribute(name: String) -> NSAttributeDescription {
        makeStringAttribute(name: name, isOptional: false)
    }

    private static func makeStringAttribute(
        name: String,
        isOptional: Bool
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = isOptional
        return attribute
    }

    private static func makeDateAttribute(name: String) -> NSAttributeDescription {
        makeDateAttribute(name: name, isOptional: false)
    }

    private static func makeDateAttribute(
        name: String,
        isOptional: Bool
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .dateAttributeType
        attribute.isOptional = isOptional
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

    private static func makeIntegerAttribute(name: String) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .integer64AttributeType
        attribute.isOptional = false
        return attribute
    }

    private static func makeBinaryDataAttribute(
        name: String,
        isOptional: Bool
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .binaryDataAttributeType
        attribute.isOptional = isOptional
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
    @NSManaged var appleUserID: String?
    @NSManaged var createdAt: Date
    @NSManaged var isNavigationStateRestoreEnabled: Bool

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<CoreDataUserEntity> {
        NSFetchRequest<CoreDataUserEntity>(entityName: entityName)
    }
}

/// Core Data entity storing a persisted home-feed card snapshot.
final class CoreDataFeedCardEntity: NSManagedObject {
    static let entityName = "CoreDataFeedCardEntity"

    @NSManaged var id: String
    @NSManaged var channelID: String
    @NSManaged var kindRawValue: String
    @NSManaged var sortOrder: Int64
    @NSManaged var remoteUpdatedAt: Date
    @NSManaged var syncedAt: Date
    @NSManaged var publishedAt: Date?

    @NSManaged var postedInPrefix: String?
    @NSManaged var sourceTitle: String?
    @NSManaged var brandTitle: String?
    @NSManaged var headline: String
    @NSManaged var summary: String?
    @NSManaged var metadataLine: String?
    @NSManaged var translationLabel: String?
    @NSManaged var articleActionsData: Data?
    @NSManaged var articleStateData: Data?

    @NSManaged var categoryTitle: String?
    @NSManaged var participantsData: Data?
    @NSManaged var joinedText: String?
    @NSManaged var discussionStateData: Data?

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<CoreDataFeedCardEntity> {
        NSFetchRequest<CoreDataFeedCardEntity>(entityName: entityName)
    }
}
