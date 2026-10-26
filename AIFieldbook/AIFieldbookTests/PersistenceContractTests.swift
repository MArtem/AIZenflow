import CryptoKit
import Foundation
import SwiftData
import XCTest
@testable import AIFieldbook

private struct MigrationPhase: Codable {
    let owner: String
    var phase: Int
    var processIDs: [Int]
}

private final class CancelAfterCopyFileManager: FileManager, @unchecked Sendable {
    enum FailurePoint: CaseIterable { case cancellationAfterCopy, copy, directoryProtection }
    let failurePoint: FailurePoint

    init(failurePoint: FailurePoint = .cancellationAfterCopy) {
        self.failurePoint = failurePoint
        super.init()
    }

    override func copyItem(at sourceURL: URL, to destinationURL: URL) throws {
        if failurePoint == .copy { throw CocoaError(.fileWriteUnknown) }
        try super.copyItem(at: sourceURL, to: destinationURL)
        withUnsafeCurrentTask { $0?.cancel() }
    }

    override func setAttributes(_ attributes: [FileAttributeKey: Any], ofItemAtPath path: String) throws {
        if failurePoint == .directoryProtection, path.contains("/Exports/AIFieldbook-Export-") {
            throw CocoaError(.fileWriteNoPermission)
        }
        try super.setAttributes(attributes, ofItemAtPath: path)
    }
}

/// Run exactly three iterations with test-repetition-relaunch-enabled YES.
/// The PID ledger rejects same-process repetition; stores never use app/user defaults.
@MainActor
final class PersistenceContractTests: XCTestCase {
    private let owner = "KB-Evolution-20261026-T2-v1"
    private let date = Date(timeIntervalSince1970: 1_700_000_000)
    private let png = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=")!

    func testPopulatedStoresMigrateAndReopenAcrossProcesses() throws {
        continueAfterFailure = false
        executionTimeAllowance = 120
        let root = fixtureRoot()
        let manager = FileManager.default
        let ledger = root.appendingPathComponent("phase.json")
        var state: MigrationPhase
        if manager.fileExists(atPath: ledger.path) {
            state = try JSONDecoder().decode(MigrationPhase.self, from: Data(contentsOf: ledger))
            XCTAssertEqual(state.owner, owner)
        } else {
            XCTAssertFalse(manager.fileExists(atPath: root.path), "Refuse an unknown fixture root")
            try manager.createDirectory(at: root, withIntermediateDirectories: true)
            state = MigrationPhase(owner: owner, phase: 0, processIDs: [])
        }
        let pid = Int(ProcessInfo.processInfo.processIdentifier)
        XCTAssertFalse(state.processIDs.contains(pid), "A fresh process is required for every phase")
        state.processIDs.append(pid)
        try JSONEncoder().encode(state).write(to: ledger, options: .atomic)

        switch state.phase {
        case 0:
            try seedV1(root)
            try seedV2(root)
        case 1:
            XCTAssertEqual(state.processIDs.count, 2)
            var backupHashes: [String: String] = [:]
            for version in [1, 2] {
                let folder = storeDirectory(root, version: version)
                let backup = root.appendingPathComponent("old-v\(version)-backup", isDirectory: true)
                // The writer from phase0 has exited: preserve the full store folder, including sidecars.
                try manager.copyItem(at: folder, to: backup)
                for (path, digest) in try hashes(backup) { backupHashes["v\(version)/" + path] = digest }
                try openCurrentAndVerify(root, version: version)
            }
            try JSONEncoder().encode(backupHashes).write(to: root.appendingPathComponent("backup-hashes.json"))
        case 2:
            XCTAssertEqual(state.processIDs.count, 3)
            for version in [1, 2] { try openCurrentAndVerify(root, version: version) }
            let expected = try JSONDecoder().decode([String: String].self, from: Data(contentsOf: root.appendingPathComponent("backup-hashes.json")))
            var observed: [String: String] = [:]
            for version in [1, 2] {
                let backup = root.appendingPathComponent("old-v\(version)-backup", isDirectory: true)
                for (path, digest) in try hashes(backup) { observed["v\(version)/" + path] = digest }
            }
            XCTAssertEqual(observed, expected, "Original store/sidecar backups changed")
            try corruptStoreMustFailWithoutReplacingBytes(root)
        default:
            XCTFail("Completed fixture cannot be silently reused; preserve it and choose a new explicit run")
            return
        }
        state.phase += 1
        try JSONEncoder().encode(state).write(to: ledger, options: .atomic)
        print("KB_T2_PHASE \(state.phase) PID \(pid) ROOT \(root.path)")
    }

    private func fixtureRoot() -> URL {
        let project = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        return project.appendingPathComponent(".zenflow/task-artifacts/kb-evolution-2026-10-26/execution/T2-store-ios\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)", isDirectory: true)
    }

    func testExportSnapshotCancellationAndOwnedCleanup() async throws {
        let root = fixtureRoot().deletingLastPathComponent()
            .appendingPathComponent("T3-export-\(UUID().uuidString)", isDirectory: true)
        let manager = FileManager.default
        XCTAssertFalse(manager.fileExists(atPath: root.path))
        try manager.createDirectory(at: root.appendingPathComponent("Content/imports"), withIntermediateDirectories: true)
        defer { try? manager.removeItem(at: root) }
        let source = root.appendingPathComponent("Content/imports/pixel.png")
        try png.write(to: source)
        let sentinel = root.appendingPathComponent("unrelated.txt")
        try Data("keep".utf8).write(to: sentinel)
        let schema = Schema(AIFieldbookSchemaV3.models)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let workspace = WorkspaceRecord(id: id(3, 1), name: "Экспорт 🧭", createdAt: date, updatedAt: date)
        let item = KnowledgeItemRecord(id: id(3, 2), kind: .image, title: "Photo", textContent: "Текст", createdAt: date, updatedAt: date, workspace: workspace)
        let attachment = AttachmentRecord(id: id(3, 3), relativePath: "imports/pixel.png", originalFilename: "pixel.png", contentType: "public.png", byteCount: Int64(png.count), createdAt: date, item: item)
        let tagZ = TagRecord(name: "Z"); let tagA = TagRecord(name: "A")
        context.insert(workspace); context.insert(item); context.insert(attachment)
        context.insert(tagZ); context.insert(tagA); item.tags = [tagZ, tagA]
        try context.save()
        let exporter = FieldbookExportService(modelContainer: container)
        let fileStore = AppFileStore(rootURL: root)
        let manifest = try await exporter.manifestData()
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: manifest) as? [String: Any])
        XCTAssertEqual(json["formatVersion"] as? Int, 2)
        XCTAssertNotNil(ISO8601DateFormatter().date(from: try XCTUnwrap(json["exportedAt"] as? String)))
        let spaces = try XCTUnwrap(json["workspaces"] as? [[String: Any]])
        XCTAssertEqual(spaces.count, 1)
        let space = try XCTUnwrap(spaces.first)
        XCTAssertEqual(space["id"] as? String, workspace.id.uuidString)
        XCTAssertEqual(space["name"] as? String, workspace.name)
        let items = try XCTUnwrap(space["items"] as? [[String: Any]])
        XCTAssertEqual(items.count, 1)
        let exportedItem = try XCTUnwrap(items.first)
        XCTAssertEqual(exportedItem["id"] as? String, item.id.uuidString)
        XCTAssertEqual(exportedItem["kind"] as? String, item.kindRawValue)
        XCTAssertEqual(exportedItem["title"] as? String, "Photo")
        XCTAssertEqual(exportedItem["textContent"] as? String, "Текст")
        XCTAssertEqual(exportedItem["tags"] as? [String], ["A", "Z"])
        XCTAssertEqual(exportedItem["files"] as? [String], ["imports/pixel.png"])
        XCTAssertEqual((exportedItem["aiResults"] as? [Any])?.count, 0)
        XCTAssertEqual(ISO8601DateFormatter().date(from: try XCTUnwrap(exportedItem["updatedAt"] as? String)), date)
        let first = try await fileStore.createExport(manifest: manifest)
        XCTAssertEqual(try Data(contentsOf: first.appendingPathComponent("manifest.json")), manifest)
        XCTAssertEqual(try Data(contentsOf: first.appendingPathComponent("Content/imports/pixel.png")), png)

        // Cancel within the task before entering the real APIs: no scheduler race or sleeps.
        let cancelledManifest = Task { () throws -> Data in
            withUnsafeCurrentTask { $0?.cancel() }
            return try await exporter.manifestData()
        }
        do { _ = try await cancelledManifest.value; XCTFail("Cancelled manifest unexpectedly succeeded") }
        catch is CancellationError { }
        catch { XCTFail("Unexpected cancellation error: \(error)") }
        let cancelledPublication = Task { () throws -> URL in
            withUnsafeCurrentTask { $0?.cancel() }
            return try await fileStore.createExport(manifest: manifest)
        }
        do { _ = try await cancelledPublication.value; XCTFail("Cancelled publication unexpectedly succeeded") }
        catch is CancellationError { }
        catch { XCTFail("Unexpected cancellation error: \(error)") }
        XCTAssertTrue(manager.fileExists(atPath: first.path), "Pre-cancel must not delete the previous export")
        let second = try await fileStore.createExport(manifest: manifest)
        XCTAssertNotEqual(first, second)
        XCTAssertFalse(manager.fileExists(atPath: first.path))
        XCTAssertEqual(try Data(contentsOf: second.appendingPathComponent("Content/imports/pixel.png")), png)
        await fileStore.cleanupExports()
        await fileStore.cleanupExports() // Idempotent owned cleanup.
        XCTAssertFalse(manager.fileExists(atPath: root.appendingPathComponent("Exports").path))
        XCTAssertEqual(try Data(contentsOf: source), png)
        XCTAssertEqual(try String(contentsOf: sentinel, encoding: .utf8), "keep")
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<KnowledgeItemRecord>()), 1)
    }

    func testCancelledExportDoesNotLeavePartialPublication() async throws {
        for point in CancelAfterCopyFileManager.FailurePoint.allCases {
            try await verifyFailedExportCleanup(at: point)
        }
    }

    private func verifyFailedExportCleanup(at point: CancelAfterCopyFileManager.FailurePoint) async throws {
        let root = fixtureRoot().deletingLastPathComponent()
            .appendingPathComponent("T3-cancel-\(UUID().uuidString)", isDirectory: true)
        let manager = FileManager.default
        try manager.createDirectory(at: root.appendingPathComponent("Content"), withIntermediateDirectories: true)
        defer { try? manager.removeItem(at: root) }
        let source = root.appendingPathComponent("Content/pixel.png")
        try png.write(to: source)
        let fileStore = AppFileStore(fileManager: CancelAfterCopyFileManager(failurePoint: point), rootURL: root)
        let publication = Task { try await fileStore.createExport(manifest: Data("{}".utf8)) }
        do { _ = try await publication.value; XCTFail("Cancelled export unexpectedly succeeded") }
        catch is CancellationError { XCTAssertEqual(point, .cancellationAfterCopy) }
        catch let error as CocoaError {
            XCTAssertNotEqual(point, .cancellationAfterCopy)
            XCTAssertEqual(error.code, point == .copy ? .fileWriteUnknown : .fileWriteNoPermission)
        }
        catch { XCTFail("Unexpected failure: \(error)") }
        let exports = root.appendingPathComponent("Exports")
        let remaining = manager.fileExists(atPath: exports.path)
            ? try manager.contentsOfDirectory(atPath: exports.path) : []
        XCTAssertTrue(remaining.isEmpty, "Cancelled publication left a partial export: \(remaining)")
        XCTAssertEqual(try Data(contentsOf: source), png)
    }

    private func storeDirectory(_ root: URL, version: Int) -> URL {
        root.appendingPathComponent("v\(version)", isDirectory: true)
    }

    private func id(_ version: Int, _ offset: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", version * 100 + offset))!
    }

    private func seedV1(_ root: URL) throws {
        let folder = storeDirectory(root, version: 1)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let schema = Schema(versionedSchema: AIFieldbookSchemaV1.self)
        let configuration = ModelConfiguration("LegacyV1", schema: schema, url: folder.appendingPathComponent("data.store"), cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let workspace = AIFieldbookSchemaV1.WorkspaceRecord(id: id(1, 1), name: "Legacy V1", createdAt: date, updatedAt: date)
        let item = AIFieldbookSchemaV1.KnowledgeItemRecord(id: id(1, 2), kindRawValue: KnowledgeItemKind.textNote.rawValue, title: "Legacy note", textContent: "Сохранить текст 🧭", createdAt: date, updatedAt: date, workspace: workspace)
        let tag = AIFieldbookSchemaV1.TagRecord(id: id(1, 3), name: "Legacy tag", createdAt: date)
        context.insert(workspace); context.insert(item); context.insert(tag)
        try context.save()
    }

    private func seedV2(_ root: URL) throws {
        let folder = storeDirectory(root, version: 2)
        try FileManager.default.createDirectory(at: folder.appendingPathComponent("imports"), withIntermediateDirectories: true)
        try png.write(to: folder.appendingPathComponent("imports/pixel.png"))
        let schema = Schema(versionedSchema: AIFieldbookSchemaV2.self)
        let configuration = ModelConfiguration("LegacyV2", schema: schema, url: folder.appendingPathComponent("data.store"), cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let workspace = AIFieldbookSchemaV2.WorkspaceRecord(id: id(2, 1), name: "Legacy V2", createdAt: date, updatedAt: date)
        let item = AIFieldbookSchemaV2.KnowledgeItemRecord(id: id(2, 2), kind: .image, title: "Legacy image", textContent: "", createdAt: date, updatedAt: date, workspace: workspace)
        let tag = AIFieldbookSchemaV2.TagRecord(id: id(2, 3), name: "Legacy tag", createdAt: date)
        let attachment = AIFieldbookSchemaV2.AttachmentRecord(id: id(2, 4), relativePath: "imports/pixel.png", originalFilename: "pixel.png", contentType: "public.png", byteCount: Int64(png.count), createdAt: date, pixelWidth: 1, pixelHeight: 1, item: item)
        context.insert(workspace); context.insert(item); context.insert(tag); context.insert(attachment)
        item.tags = [tag]
        try context.save()
    }

    private func openCurrentAndVerify(_ root: URL, version: Int) throws {
        let folder = storeDirectory(root, version: version)
        let schema = Schema(AIFieldbookSchemaV3.models) // Same schema construction as PersistenceBootstrap.
        let configuration = ModelConfiguration("Current", schema: schema, url: folder.appendingPathComponent("data.store"), cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, migrationPlan: AIFieldbookMigrationPlan.self, configurations: [configuration])
        let context = ModelContext(container)
        let workspaces = try context.fetch(FetchDescriptor<WorkspaceRecord>())
        let items = try context.fetch(FetchDescriptor<KnowledgeItemRecord>())
        let tags = try context.fetch(FetchDescriptor<TagRecord>())
        let attachments = try context.fetch(FetchDescriptor<AttachmentRecord>())
        XCTAssertEqual(workspaces.count, 1); XCTAssertEqual(items.count, 1); XCTAssertEqual(tags.count, 1)
        let workspace = try XCTUnwrap(workspaces.first); let item = try XCTUnwrap(items.first)
        XCTAssertEqual(workspace.id, id(version, 1)); XCTAssertEqual(workspace.name, "Legacy V\(version)")
        XCTAssertEqual(workspace.createdAt, date); XCTAssertEqual(workspace.updatedAt, date)
        XCTAssertEqual(workspace.items.map(\.id), [id(version, 2)])
        XCTAssertEqual(item.id, id(version, 2)); XCTAssertEqual(item.workspace?.id, workspace.id)
        XCTAssertEqual(item.createdAt, date); XCTAssertEqual(item.updatedAt, date)
        XCTAssertTrue(item.aiResults.isEmpty)
        XCTAssertEqual(tags.first?.id, id(version, 3)); XCTAssertEqual(tags.first?.name, "Legacy tag")
        if version == 1 {
            XCTAssertEqual(item.kind, .textNote); XCTAssertEqual(item.title, "Legacy note")
            XCTAssertEqual(item.textContent, "Сохранить текст 🧭")
            XCTAssertTrue(item.tags.isEmpty); XCTAssertTrue(attachments.isEmpty)
            XCTAssertTrue(try XCTUnwrap(tags.first).items.isEmpty)
        } else {
            XCTAssertEqual(item.kind, .image); XCTAssertEqual(item.title, "Legacy image")
            XCTAssertEqual(item.tags.map(\.id), [id(2, 3)])
            XCTAssertEqual(try XCTUnwrap(tags.first).items.map(\.id), [item.id])
            XCTAssertEqual(attachments.count, 1)
            let attachment = try XCTUnwrap(attachments.first)
            XCTAssertEqual(item.attachments.map(\.id), [attachment.id])
            XCTAssertEqual(attachment.id, id(2, 4)); XCTAssertEqual(attachment.item?.id, item.id)
            XCTAssertEqual(attachment.relativePath, "imports/pixel.png")
            XCTAssertEqual(attachment.originalFilename, "pixel.png"); XCTAssertEqual(attachment.contentType, "public.png")
            XCTAssertEqual(attachment.byteCount, Int64(png.count)); XCTAssertEqual(attachment.createdAt, date)
            XCTAssertEqual(attachment.pixelWidth, 1); XCTAssertEqual(attachment.pixelHeight, 1)
            XCTAssertNil(attachment.durationSeconds); XCTAssertNil(attachment.pageCount)
            XCTAssertEqual(try Data(contentsOf: folder.appendingPathComponent(attachment.relativePath)), png)
        }
    }

    private func corruptStoreMustFailWithoutReplacingBytes(_ root: URL) throws {
        let url = root.appendingPathComponent("corrupt.store")
        let original = Data("KB owned corrupt store; do not replace".utf8)
        try original.write(to: url, options: .withoutOverwriting)
        let schema = Schema(AIFieldbookSchemaV3.models)
        let configuration = ModelConfiguration("Corrupt", schema: schema, url: url, cloudKitDatabase: .none)
        XCTAssertThrowsError(try ModelContainer(for: schema, migrationPlan: AIFieldbookMigrationPlan.self, configurations: [configuration]))
        XCTAssertEqual(try Data(contentsOf: url), original)
    }

    private func hashes(_ root: URL) throws -> [String: String] {
        let enumeration = try XCTUnwrap(FileManager.default.enumerator(at: root, includingPropertiesForKeys: [.isRegularFileKey]))
        var result: [String: String] = [:]
        for case let url as URL in enumeration {
            if try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true {
                let relative = String(url.path.dropFirst(root.path.count + 1))
                result[relative] = SHA256.hash(data: try Data(contentsOf: url)).map { String(format: "%02x", $0) }.joined()
            }
        }
        return result
    }
}
