import Foundation
import Testing
@testable import TchopShareSupport

/// Verifies share-support app-group JSON storage and item import contracts.
struct TchopShareSupportTests {
    @Test
    func savesLoadsAndRemovesItems() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileManager = TestAppGroupFileManager(containerURL: rootURL)
        let store = try AppGroupJSONItemDirectoryStore<TestItem>(
            groupIdentifier: "group.test.share-support",
            directoryName: "pending",
            fileManager: fileManager
        )

        let item = TestItem(id: "item-1", value: "hello")
        try store.save(item)

        #expect(try store.loadAll() == [item])

        try store.remove(id: item.id)
        #expect(try store.loadAll().isEmpty)
    }

    @Test
    func clearsDirectory() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileManager = TestAppGroupFileManager(containerURL: rootURL)
        let store = try AppGroupJSONItemDirectoryStore<TestItem>(
            groupIdentifier: "group.test.share-support",
            directoryName: "pending",
            fileManager: fileManager
        )

        try store.save(TestItem(id: "item-1", value: "one"))
        try store.save(TestItem(id: "item-2", value: "two"))

        try store.clear()

        #expect(try store.loadAll().isEmpty)
    }
}

private struct TestItem: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let value: String
}

private final class TestAppGroupFileManager: FileManager, @unchecked Sendable {
    private let sharedContainerURL: URL

    init(containerURL: URL) {
        self.sharedContainerURL = containerURL
        super.init()
    }

    override func containerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL? {
        sharedContainerURL
    }
}
