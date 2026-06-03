import Foundation
import Testing
import UniformTypeIdentifiers
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

    @Test
    func savingSameIDReplacesCurrentValue() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileManager = TestAppGroupFileManager(containerURL: rootURL)
        let store = try AppGroupJSONItemDirectoryStore<TestItem>(
            groupIdentifier: "group.test.share-support",
            directoryName: "pending",
            fileManager: fileManager
        )

        try store.save(TestItem(id: "item-1", value: "first"))
        try store.save(TestItem(id: "item-1", value: "second"))

        #expect(try store.loadAll() == [TestItem(id: "item-1", value: "second")])
    }

    @Test
    func safeLoadSeparatesValidAndCorruptDirectoryItems() throws {
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
        try "not-json".write(
            to: rootURL
                .appendingPathComponent("pending", isDirectory: true)
                .appendingPathComponent("corrupt.json"),
            atomically: true,
            encoding: .utf8
        )

        let result = try store.loadAllSafely()

        #expect(result.items == [item])
        #expect(result.failedFileURLs.map(\.lastPathComponent) == ["corrupt.json"])
    }

    @Test
    func quarantinesCorruptDirectoryItems() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileManager = TestAppGroupFileManager(containerURL: rootURL)
        let store = try AppGroupJSONItemDirectoryStore<TestItem>(
            groupIdentifier: "group.test.share-support",
            directoryName: "pending",
            fileManager: fileManager
        )
        let directoryURL = rootURL.appendingPathComponent("pending", isDirectory: true)
        let corruptFileURL = directoryURL.appendingPathComponent("corrupt.json")
        try "not-json".write(to: corruptFileURL, atomically: true, encoding: .utf8)

        try store.quarantineFiles([corruptFileURL])

        #expect(!FileManager.default.fileExists(atPath: corruptFileURL.path()))
        let quarantinedFiles = try FileManager.default.contentsOfDirectory(
            at: directoryURL.appendingPathComponent("corrupted", isDirectory: true),
            includingPropertiesForKeys: nil
        )
        #expect(quarantinedFiles.count == 1)
        #expect(quarantinedFiles[0].lastPathComponent.hasSuffix("corrupt.json"))
    }

    @Test
    func quarantineSkipsFileThatWasReplacedWithValidCurrentValue() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileManager = TestAppGroupFileManager(containerURL: rootURL)
        let store = try AppGroupJSONItemDirectoryStore<TestItem>(
            groupIdentifier: "group.test.share-support",
            directoryName: "pending",
            fileManager: fileManager
        )
        let directoryURL = rootURL.appendingPathComponent("pending", isDirectory: true)
        let itemFileURL = directoryURL.appendingPathComponent("item-1.json")
        try "not-json".write(to: itemFileURL, atomically: true, encoding: .utf8)
        let staleLoadResult = try store.loadAllSafely()

        let recoveredItem = TestItem(id: "item-1", value: "recovered")
        try store.save(recoveredItem)
        try store.quarantineFiles(staleLoadResult.failedFileURLs)

        #expect(try store.loadAll() == [recoveredItem])
        let quarantineDirectoryURL = directoryURL.appendingPathComponent("corrupted", isDirectory: true)
        let quarantinedFiles = try FileManager.default.contentsOfDirectory(
            at: quarantineDirectoryURL,
            includingPropertiesForKeys: nil
        )
        #expect(quarantinedFiles.isEmpty)
    }

    @Test
    func itemDirectoryStoreSupportsConcurrentUniqueItemWrites() async throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileManager = TestAppGroupFileManager(containerURL: rootURL)
        let store = try AppGroupJSONItemDirectoryStore<TestItem>(
            groupIdentifier: "group.test.share-support",
            directoryName: "pending",
            fileManager: fileManager
        )

        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0..<50 {
                group.addTask {
                    try store.save(TestItem(id: "item-\(index)", value: "\(index)"))
                }
            }
            try await group.waitForAll()
        }

        #expect(try store.loadAllSafely().items.count == 50)
    }

    @Test
    func singleFileStoreSavesLoadsAndClearsSnapshot() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileManager = TestAppGroupFileManager(containerURL: rootURL)
        let store = try AppGroupJSONFileStore<TestItem>(
            groupIdentifier: "group.test.share-support",
            directoryName: "snapshots",
            fileName: "current",
            fileManager: fileManager
        )

        #expect(try store.load() == nil)

        let item = TestItem(id: "item-1", value: "snapshot")
        try store.save(item)
        #expect(try store.load() == item)

        try store.clear()
        #expect(try store.load() == nil)
    }

    @MainActor
    @Test
    func importerLoadsPlainTextProviders() async throws {
        let importer = try NSItemProviderShareItemImporter()
        let provider = NSItemProvider(item: "shared text" as NSString, typeIdentifier: UTType.plainText.identifier)

        let items = try await importer.loadItems(from: [provider])

        #expect(items.count == 1)
        guard case let .text(textItem) = try #require(items.first) else {
            Issue.record("Expected text item")
            return
        }
        #expect(textItem.text == "shared text")
    }

    @MainActor
    @Test
    func importerRejectsUnsupportedProviders() async throws {
        let importer = try NSItemProviderShareItemImporter()
        let provider = NSItemProvider(item: NSData(data: Data([0x01])), typeIdentifier: UTType.data.identifier)

        do {
            _ = try await importer.loadItems(from: [provider])
            Issue.record("Expected unsupported provider error")
        } catch let error as ShareItemImportError {
            #expect(error == .unsupportedProvider)
        }
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
