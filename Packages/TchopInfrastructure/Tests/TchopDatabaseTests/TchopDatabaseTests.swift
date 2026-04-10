import SwiftData
import XCTest
@testable import TchopDatabase

@Model
private final class TestRecord {
    @Attribute(.unique) var id: String
    var title: String

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

@MainActor
final class TchopDatabaseTests: XCTestCase {
    func testInMemorySwiftDataManagerCanInsertAndFetch() throws {
        let schema = Schema([TestRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let manager = SwiftDataDatabaseManager(modelContainer: container)

        manager.insert(TestRecord(id: "1", title: "First"))
        try manager.save()

        let records = try manager.fetch(FetchDescriptor<TestRecord>())

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.title, "First")
    }
}
