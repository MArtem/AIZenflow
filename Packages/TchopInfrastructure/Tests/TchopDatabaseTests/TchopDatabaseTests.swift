import CoreData
import SwiftData
import XCTest
@testable import TchopDatabase

@available(iOS 17, macOS 14, *)
@Model
private final class SwiftDataTestRecord {
    @Attribute(.unique) var id: String
    var title: String

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

@MainActor
final class TchopDatabaseTests: XCTestCase {
    /// Verifies that the SwiftData manager executes the backend-neutral read/write contract.
    @available(iOS 17, macOS 14, *)
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
                let entity = CoreDataTestRecord(context: context)
                entity.id = "1"
                entity.title = "First"
            })
        )

        let records = try manager.read(
            DatabaseReadOperation(coreData: { context in
                try context.fetch(CoreDataTestRecord.fetchRequest())
            })
        )

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.title, "First")
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

    /// Verifies that the service factory selects the requested backend correctly.
    @available(iOS 17, macOS 14, *)
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

    @available(iOS 17, macOS 14, *)
    private func makeInMemorySwiftDataContainer() throws -> ModelContainer {
        let schema = Schema([SwiftDataTestRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private func makeInMemoryCoreDataContainer() throws -> NSPersistentContainer {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = CoreDataTestRecord.entityName
        entity.managedObjectClassName = NSStringFromClass(CoreDataTestRecord.self)
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

    private func makeStringAttribute(name: String) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        return attribute
    }
}

private final class CoreDataTestRecord: NSManagedObject {
    static let entityName = "CoreDataTestRecord"

    @NSManaged var id: String
    @NSManaged var title: String

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<CoreDataTestRecord> {
        NSFetchRequest<CoreDataTestRecord>(entityName: entityName)
    }
}
