import CoreData
import SwiftData
import XCTest
@testable import TchopDatabase

@available(iOS 17, macOS 14, *)
@Model
private final class SwiftDataTestRecord {
    @Attribute(.unique) var id: String
    var title: String

    /// Creates a new SwiftDataTestRecord instance.
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

@MainActor
final class TchopDatabaseTests: XCTestCase {
    /// Verifies that the SwiftData manager executes the backend-neutral read/write contract.
    @available(iOS 17, macOS 14, *)
    /// Verifies swift data manager can insert and fetch through unified contract.
    func testSwiftDataManagerCanInsertAndFetchThroughUnifiedContract() throws {
        let schema = Schema([SwiftDataTestRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let manager = SwiftDataDatabaseManager(modelContainer: container)

        try manager.write(
            DatabaseWriteOperation { context in
                context.insert(SwiftDataTestRecord(id: "1", title: "First"))
            }
        )

        let records = try manager.read(
            DatabaseReadOperation { context in
                try context.fetch(FetchDescriptor<SwiftDataTestRecord>())
            }
        )

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.title, "First")
    }

    /// Verifies that the Core Data manager executes the same contract successfully.
    func testCoreDataManagerCanInsertAndFetchThroughUnifiedContract() throws {
        let manager = CoreDataDatabaseManager(
            persistentContainer: try makeInMemoryCoreDataContainer()
        )

        try manager.write(
            DatabaseWriteOperation(coreData: { context in
                let entity = self.makeCoreDataTestRecord(in: context)
                entity.setValue("1", forKey: "id")
                entity.setValue("First", forKey: "title")
            })
        )

        let records = try manager.read(
            DatabaseReadOperation(coreData: { context in
                try context.fetch(self.makeCoreDataTestFetchRequest())
            })
        )

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.value(forKey: "title") as? String, "First")
    }

    /// Verifies that batch writes use the same transactional semantics.
    func testCoreDataManagerCanExecuteBatchWrite() throws {
        let manager = CoreDataDatabaseManager(
            persistentContainer: try makeInMemoryCoreDataContainer()
        )

        try manager.writeBatch(
            DatabaseBatchWriteOperation(coreData: { context in
                for index in 1 ... 3 {
                    let entity = self.makeCoreDataTestRecord(in: context)
                    entity.setValue("\(index)", forKey: "id")
                    entity.setValue("Title \(index)", forKey: "title")
                }
            })
        )

        let records = try manager.read(
            DatabaseReadOperation(coreData: { context in
                try context.fetch(self.makeCoreDataTestFetchRequest())
            })
        )

        XCTAssertEqual(records.count, 3)
    }

    /// Verifies that the service factory selects the requested backend correctly.
    func testDatabaseFactoryCreatesCoreDataManagerWhenRequested() throws {
        let manager = try DatabaseServiceFactory.makeDatabaseManager(
            configuration: DatabaseConfiguration(
                backendSelectionPolicy: .coreData,
                isStoredInMemoryOnly: true
            ),
            makeCoreDataContainer: makeInMemoryCoreDataContainer
        )

        XCTAssertEqual(manager.backendKind, .coreData)
    }

    /// Verifies that the new resolver protocol can construct a Core Data backend directly.
    func testDatabaseManagerResolverCreatesCoreDataManagerWhenRequested() throws {
        let resolver: any DatabaseManagerResolving = DatabaseManagerResolver()
        let manager = try resolver.makeDatabaseManager(
            configuration: DatabaseConfiguration(
                backendSelectionPolicy: .coreData,
                isStoredInMemoryOnly: true
            ),
            makeCoreDataContainer: makeInMemoryCoreDataContainer
        )

        XCTAssertEqual(manager.backendKind, .coreData)
    }

    /// Verifies that the factory-set API reports only actually constructible backends.
    func testDatabaseFactorySetReportsAvailableCoreDataBackend() throws {
        let factories = DatabaseManagerFactorySet(
            makeCoreDataContainer: makeInMemoryCoreDataContainer
        )

        XCTAssertEqual(DatabaseServiceFactory.availableBackends(for: factories), [.coreData])
    }

    /// Verifies that the service factory selects the requested backend correctly.
    @available(iOS 17, macOS 14, *)
    /// Verifies database factory creates swift data manager when requested.
    func testDatabaseFactoryCreatesSwiftDataManagerWhenRequested() throws {
        let manager = try DatabaseServiceFactory.makeDatabaseManager(
            configuration: DatabaseConfiguration(
                backendSelectionPolicy: .swiftData,
                isStoredInMemoryOnly: true
            ),
            makeSwiftDataContainer: makeInMemorySwiftDataContainer
        )

        XCTAssertEqual(manager.backendKind, .swiftData)
    }

    /// Verifies that the unified factory-set API can resolve both backends from one payload.
    @available(iOS 17, macOS 14, *)
    /// Verifies database factory set can create requested backend.
    func testDatabaseFactorySetCanCreateRequestedBackend() throws {
        let factories = DatabaseManagerFactorySet(
            makeSwiftDataContainer: makeInMemorySwiftDataContainer,
            makeCoreDataContainer: makeInMemoryCoreDataContainer
        )

        XCTAssertEqual(
            DatabaseServiceFactory.availableBackends(for: factories),
            [.swiftData, .coreData]
        )

        let swiftDataManager = try DatabaseServiceFactory.makeDatabaseManager(
            configuration: DatabaseConfiguration(
                backendSelectionPolicy: .swiftData,
                isStoredInMemoryOnly: true
            ),
            factories: factories
        )
        XCTAssertEqual(swiftDataManager.backendKind, .swiftData)

        let coreDataManager = try DatabaseServiceFactory.makeDatabaseManager(
            configuration: DatabaseConfiguration(
                backendSelectionPolicy: .coreData,
                isStoredInMemoryOnly: true
            ),
            factories: factories
        )
        XCTAssertEqual(coreDataManager.backendKind, .coreData)
    }

    /// Verifies that the new resolver protocol can construct a SwiftData backend directly.
    @available(iOS 17, macOS 14, *)
    /// Verifies database manager resolver creates swift data manager when requested.
    func testDatabaseManagerResolverCreatesSwiftDataManagerWhenRequested() throws {
        let resolver: any DatabaseManagerResolving = DatabaseManagerResolver()
        let manager = try resolver.makeDatabaseManager(
            configuration: DatabaseConfiguration(
                backendSelectionPolicy: .swiftData,
                isStoredInMemoryOnly: true
            ),
            makeSwiftDataContainer: makeInMemorySwiftDataContainer
        )

        XCTAssertEqual(manager.backendKind, .swiftData)
    }

    /// Verifies that migration runner applies ordered steps and stores resulting version.
    func testMigrationRunnerAppliesVersionedPlan() throws {
        let manager = CoreDataDatabaseManager(
            persistentContainer: try makeInMemoryCoreDataContainer()
        )
        let versionStore = InMemoryMigrationVersionStore()
        let runner = DatabaseMigrationRunner(versionStore: versionStore)

        let steps = [
            DatabaseMigrationStep(fromVersion: 0, toVersion: 1, migrate: { _ in }),
            DatabaseMigrationStep(fromVersion: 1, toVersion: 2, migrate: { db in
                try db.writeBatch(
                    DatabaseBatchWriteOperation(coreData: { context in
                        let entity = self.makeCoreDataTestRecord(in: context)
                        entity.setValue("migrated", forKey: "id")
                        entity.setValue("From migration", forKey: "title")
                    })
                )
            })
        ]

        let appliedVersion = try runner.migrateIfNeeded(
            key: "main_store",
            targetVersion: 2,
            using: manager,
            steps: steps
        )

        XCTAssertEqual(appliedVersion, 2)
        XCTAssertEqual(versionStore.currentVersion(for: "main_store"), 2)

        let records = try manager.read(
            DatabaseReadOperation(coreData: { context in
                try context.fetch(self.makeCoreDataTestFetchRequest())
            })
        )
        XCTAssertEqual(records.first?.value(forKey: "id") as? String, "migrated")
    }

    @available(iOS 17, macOS 14, *)
    /// Creates in memory swift data container.
    private func makeInMemorySwiftDataContainer() throws -> ModelContainer {
        let schema = Schema([SwiftDataTestRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Creates in memory core data container.
    private func makeInMemoryCoreDataContainer() throws -> NSPersistentContainer {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = CoreDataTestRecordSchema.entityName
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entity.properties = [
            makeStringAttribute(name: "id"),
            makeStringAttribute(name: "title")
        ]
        entity.uniquenessConstraints = [["id"]]
        model.entities = [entity]

        let container = NSPersistentContainer(
            name: "TchopDatabaseTests",
            managedObjectModel: model
        )

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]

        var persistentStoreError: Error?
        container.loadPersistentStores { _, error in
            persistentStoreError = error
        }

        if let persistentStoreError {
            throw persistentStoreError
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }

    /// Creates string attribute.
    private func makeStringAttribute(name: String) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        return attribute
    }

    /// Creates a Core Data test record without relying on subclass-to-entity lookup.
    private func makeCoreDataTestRecord(in context: NSManagedObjectContext) -> NSManagedObject {
        NSEntityDescription.insertNewObject(
            forEntityName: CoreDataTestRecordSchema.entityName,
            into: context
        )
    }

    /// Creates an explicit fetch request for the Core Data test entity.
    private func makeCoreDataTestFetchRequest() -> NSFetchRequest<NSManagedObject> {
        NSFetchRequest<NSManagedObject>(entityName: CoreDataTestRecordSchema.entityName)
    }
}

@MainActor
private final class InMemoryMigrationVersionStore: DatabaseMigrationVersionStoring {
    private var values: [String: Int] = [:]

    /// Returns version.
    func currentVersion(for key: String) -> Int {
        values[key, default: 0]
    }

    /// Sets current version.
    func setCurrentVersion(_ version: Int, for key: String) {
        values[key] = version
    }
}

private enum CoreDataTestRecordSchema {
    static let entityName = "CoreDataTestRecord"
}
