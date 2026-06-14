import XCTest
@testable import AppDownloads
import Foundation

final class AppDownloadsTests: XCTestCase {
    func testSafeDownloadFileNameRejectsTraversalAndSeparators() throws {
        XCTAssertThrowsError(try SafeDownloadFileName("../a.txt"))
        XCTAssertThrowsError(try SafeDownloadFileName("folder/a.txt"))
        XCTAssertThrowsError(try SafeDownloadFileName("folder\\a.txt"))
        XCTAssertEqual(SafeDownloadFileName.sanitized(" folder/a?.txt ").value, "folder-a-.txt")
    }

    func testURLRedactionRemovesQueryAndFragmentFromDescription() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/private/file.pdf?user=123#frag"))
        let request = try DownloadRequest(url: url)
        let rendered = request.description
        XCTAssertFalse(rendered.contains("user=123"))
        XCTAssertFalse(rendered.contains("frag"))
        XCTAssertFalse(rendered.contains("/private/file.pdf"))
        XCTAssertTrue(rendered.contains("RedactedDownloadURL"))
    }

    func testDownloadRequestRejectsInsecureSchemeByDefault() throws {
        let url = try XCTUnwrap(URL(string: "http://example.com/file.pdf"))
        XCTAssertThrowsError(try DownloadRequest(url: url)) { error in
            XCTAssertEqual(error as? DownloadFailure, DownloadFailure(.invalidURL, operation: .validation))
        }
    }

    func testDownloadRequestAllowsInsecureSchemeOnlyWhenExplicitlyConfigured() throws {
        let url = try XCTUnwrap(URL(string: "http://localhost/file.pdf"))
        let request = try DownloadRequest(url: url, allowedSchemes: ["https", "http"])
        XCTAssertEqual(request.url, url)
    }

    func testFileSystemWorkerWritesAndReturnsRedactedReceipt() async throws {
        let root = try TestScratch.makeDirectory(named: "write")
        defer { TestScratch.remove(root) }
        let directory = try DownloadDirectory(role: .custom(label: "unit"), url: root)
        let destination = DownloadDestination(directory: directory, fileName: try SafeDownloadFileName("sample.txt"))
        let worker = DownloadFileSystemWorker()
        let receipt = try await worker.writeAtomically(data: Data("hello".utf8), to: destination)
        XCTAssertEqual(receipt.byteCount, 5)
        XCTAssertEqual(try String(contentsOf: root.appendingPathComponent("sample.txt"), encoding: .utf8), "hello")
        XCTAssertFalse(receipt.description.contains("sample.txt"))
        XCTAssertFalse(directory.description.contains(root.path))
    }

    func testMakeUniqueNamePolicyCreatesSecondName() async throws {
        let root = try TestScratch.makeDirectory(named: "unique")
        defer { TestScratch.remove(root) }
        let directory = try DownloadDirectory(role: .custom(label: "unit"), url: root)
        let worker = DownloadFileSystemWorker()
        let first = DownloadDestination(directory: directory, fileName: try SafeDownloadFileName("asset.txt"), replacementPolicy: .replaceExisting)
        let second = DownloadDestination(directory: directory, fileName: try SafeDownloadFileName("asset.txt"), replacementPolicy: .makeUniqueName)
        _ = try await worker.writeAtomically(data: Data("one".utf8), to: first)
        let secondReceipt = try await worker.writeAtomically(data: Data("two".utf8), to: second)
        XCTAssertEqual(secondReceipt.fileName.value, "asset-1.txt")
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("asset.txt").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("asset-1.txt").path))
    }

    func testReplaceExistingPolicyUpdatesFileAndCleansWorkFile() async throws {
        let root = try TestScratch.makeDirectory(named: "replace")
        defer { TestScratch.remove(root) }
        let directory = try DownloadDirectory(role: .custom(label: "unit"), url: root)
        let destination = DownloadDestination(directory: directory, fileName: try SafeDownloadFileName("asset.txt"))
        let worker = DownloadFileSystemWorker()

        _ = try await worker.writeAtomically(data: Data("old".utf8), to: destination)
        _ = try await worker.writeAtomically(data: Data("new".utf8), to: destination)

        XCTAssertEqual(try String(contentsOf: root.appendingPathComponent("asset.txt"), encoding: .utf8), "new")
        let leftovers = try FileManager.default.contentsOfDirectory(atPath: root.path).filter { $0.hasPrefix(".appdownloads-work-") }
        XCTAssertTrue(leftovers.isEmpty)
    }

    func testDownloadServiceUsesInjectedTransport() async throws {
        let root = try TestScratch.makeDirectory(named: "service")
        defer { TestScratch.remove(root) }
        let directory = try DownloadDirectory(role: .custom(label: "unit"), url: root)
        let destination = DownloadDestination(directory: directory, fileName: try SafeDownloadFileName("payload.bin"))
        let request = try DownloadRequest(id: try DownloadID("test-download"), url: try XCTUnwrap(URL(string: "https://example.com/payload.bin")))
        let service = DownloadService(transport: StaticDownloadTransport(data: Data([1, 2, 3])))
        let receipt = try await service.download(request, to: destination)
        XCTAssertEqual(receipt.id.value, "test-download")
        XCTAssertEqual(receipt.byteCount, 3)
        XCTAssertEqual(try Data(contentsOf: root.appendingPathComponent("payload.bin")), Data([1, 2, 3]))
    }

    func testDownloadServiceRejectsOversizedExpectedResponseBeforeWriting() async throws {
        let root = try TestScratch.makeDirectory(named: "oversized")
        defer { TestScratch.remove(root) }
        let directory = try DownloadDirectory(role: .custom(label: "unit"), url: root)
        let destination = DownloadDestination(directory: directory, fileName: try SafeDownloadFileName("payload.bin"))
        let request = try DownloadRequest(url: try XCTUnwrap(URL(string: "https://example.com/payload.bin")), maximumAllowedBytes: 4)
        let service = DownloadService(transport: StaticDownloadTransport(data: Data([1]), expectedBytes: 5))

        do {
            _ = try await service.download(request, to: destination)
            XCTFail("Expected responseTooLarge")
        } catch let error as DownloadFailure {
            XCTAssertEqual(error, DownloadFailure(.responseTooLarge, operation: .transport))
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("payload.bin").path))
    }

    func testFailIfExistsPolicyPreservesExistingFile() async throws {
        let root = try TestScratch.makeDirectory(named: "replace-existing")
        defer { TestScratch.remove(root) }
        let directory = try DownloadDirectory(role: .custom(label: "unit"), url: root)
        let fileName = try SafeDownloadFileName("payload.bin")
        let existingURL = root.appendingPathComponent(fileName.value)
        try Data("old".utf8).write(to: existingURL)

        let worker = DownloadFileSystemWorker()
        let destination = DownloadDestination(
            directory: directory,
            fileName: fileName,
            replacementPolicy: .failIfExists
        )

        do {
            _ = try await worker.writeAtomically(data: Data("new".utf8), to: destination)
            XCTFail("Expected invalid destination")
        } catch let error as DownloadFailure {
            XCTAssertEqual(error, DownloadFailure(.invalidDestination, operation: .fileSystem))
        }
        XCTAssertEqual(try String(contentsOf: existingURL, encoding: .utf8), "old")
    }

    func testCleanupPolicyRemovesOldFiles() async throws {
        let root = try TestScratch.makeDirectory(named: "cleanup")
        defer { TestScratch.remove(root) }
        let directory = try DownloadDirectory(role: .custom(label: "unit"), url: root)
        let oldURL = root.appendingPathComponent("old.txt")
        try Data("old".utf8).write(to: oldURL)
        let oldDate = Date(timeIntervalSince1970: 100)
        try FileManager.default.setAttributes([.modificationDate: oldDate], ofItemAtPath: oldURL.path)
        let worker = DownloadCleanupWorker()
        let removed = try await worker.cleanup(directory: directory, policy: DownloadCleanupPolicy(maximumAge: 10), now: Date(timeIntervalSince1970: 200))
        XCTAssertEqual(removed, 1)
        XCTAssertFalse(FileManager.default.fileExists(atPath: oldURL.path))
    }
}

private struct StaticDownloadTransport: DownloadTransport {
    let data: Data
    var expectedBytes: Int64?

    func response(for request: DownloadRequest) async throws -> DownloadResponse {
        DownloadResponse(data: data, expectedBytes: expectedBytes ?? Int64(data.count))
    }
}

private enum TestScratch {
    static func makeDirectory(named name: String) throws -> URL {
        let base = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
            .appendingPathComponent("TestScratch", isDirectory: true)
            .appendingPathComponent(name + "-" + UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }

    static func remove(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
        }
    }
}
