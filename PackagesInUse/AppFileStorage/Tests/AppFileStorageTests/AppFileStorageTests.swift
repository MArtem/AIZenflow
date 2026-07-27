import XCTest
@testable import AppFileStorage

final class AppFileStorageTests: XCTestCase {
    private func makeStorage(name: String = UUID().uuidString) -> (LocalFileStorage, URL) {
        let base = makeTestBaseURL(name: name)
        let provider = StaticFileStorageDirectoryProvider(baseURL: base)
        let storage = LocalFileStorage(root: .custom(FileStorageNamespace("test-root")), namespace: FileStorageNamespace("suite"), directoryProvider: provider)
        return (storage, base)
    }

    private func makeTestBaseURL(name: String) -> URL {
        if let configuredBasePath = ProcessInfo.processInfo.environment["APP_FILE_STORAGE_TEST_BASE"], !configuredBasePath.isEmpty {
            return URL(fileURLWithPath: configuredBasePath, isDirectory: true)
                .appendingPathComponent(name, isDirectory: true)
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
            .deletingLastPathComponent()
            .appendingPathComponent("WorktreeScratch/AppFileStorageTests", isDirectory: true)
            .appendingPathComponent(name, isDirectory: true)
    }

    func testRelativePathRejectsEmptyPath() throws {
        XCTAssertThrowsError(try FileStorageRelativePath([]))
    }

    func testRelativePathRejectsTraversal() throws {
        XCTAssertThrowsError(try FileStorageRelativePath(["safe", "..", "file.txt"]))
    }

    func testRelativePathRejectsSeparatorsInsideComponent() throws {
        XCTAssertThrowsError(try FileStorageRelativePath(["folder/file.txt"]))
        XCTAssertThrowsError(try FileStorageRelativePath(["folder\\file.txt"]))
    }

    func testSafeFileNameReplacesUnsafeCharacters() {
        XCTAssertEqual(FileStoragePathSanitizer.safeFileName(for: " report 01?.json "), "report-01-.json")
    }

    func testWriteReadExistsAndRemove() async throws {
        let (storage, _) = makeStorage()
        let path = try FileStorageRelativePath("folder", "file.txt")
        let data = Data("hello".utf8)

        try await storage.write(data, to: path, options: .default)
        let existsAfterWrite = await storage.exists(path)
        XCTAssertTrue(existsAfterWrite)
        let loaded = try await storage.read(from: path, options: .default)
        XCTAssertEqual(loaded, data)

        try await storage.remove(path)
        let existsAfterRemove = await storage.exists(path)
        XCTAssertFalse(existsAfterRemove)
    }

    func testSynchronousCopySupportsSystemCallbackUseCases() throws {
        let base = makeTestBaseURL(name: UUID().uuidString)
        let sourceDirectory = base.appendingPathComponent("sync-sources", isDirectory: true)
        try FileManager.default.createDirectory(at: sourceDirectory, withIntermediateDirectories: true)
        let sourceURL = sourceDirectory.appendingPathComponent("source.bin", isDirectory: false)
        try Data("sync-copy".utf8).write(to: sourceURL)
        let provider = StaticFileStorageDirectoryProvider(baseURL: base)
        let path = try FileStorageRelativePath("sync.bin")

        let destinationURL = try FileStorageSynchronousOperations.copyFile(
            from: sourceURL,
            to: path,
            root: .custom(FileStorageNamespace("sync-root")),
            namespace: FileStorageNamespace("suite"),
            directoryProvider: provider
        )

        XCTAssertEqual(try Data(contentsOf: destinationURL), Data("sync-copy".utf8))
    }

    func testCopyFileCopiesWithoutLoadingThroughPublicAPI() async throws {
        let (storage, base) = makeStorage()
        let sourceDirectory = base.appendingPathComponent("sources", isDirectory: true)
        try FileManager.default.createDirectory(at: sourceDirectory, withIntermediateDirectories: true)
        let sourceURL = sourceDirectory.appendingPathComponent("source.bin", isDirectory: false)
        try Data("copied".utf8).write(to: sourceURL)
        let path = try FileStorageRelativePath("copied.bin")

        try await storage.copyFile(from: sourceURL, to: path, options: .default)

        let fileURL = try await storage.fileURL(for: path)
        XCTAssertEqual(try Data(contentsOf: fileURL), Data("copied".utf8))
    }

    func testWriteWithoutReplaceFailsWhenFileExists() async throws {
        let (storage, _) = makeStorage()
        let path = try FileStorageRelativePath("file.txt")
        try await storage.write(Data("one".utf8), to: path, options: .default)

        do {
            try await storage.write(Data("two".utf8), to: path, options: [.atomic, .createIntermediateDirectories])
            XCTFail("Expected write to fail")
        } catch let error as FileStorageError {
            XCTAssertEqual(error, .writeFailed(code: "file_exists"))
        }
    }

    func testReadMissingFileThrowsFileNotFound() async throws {
        let (storage, _) = makeStorage()
        let path = try FileStorageRelativePath("missing.txt")
        do {
            _ = try await storage.read(from: path, options: .default)
            XCTFail("Expected read to fail")
        } catch let error as FileStorageError {
            XCTAssertEqual(error, .fileNotFound)
        }
    }

    func testAttributesContainSize() async throws {
        let (storage, _) = makeStorage()
        let path = try FileStorageRelativePath("file.txt")
        try await storage.write(Data("abc".utf8), to: path, options: .default)

        let attributes = try await storage.attributes(for: path)
        XCTAssertEqual(attributes.sizeInBytes, 3)
        XCTAssertTrue(attributes.isRegularFile)
    }

    func testListFilesReturnsRecursiveEntriesSorted() async throws {
        let (storage, _) = makeStorage()
        try await storage.write(Data("b".utf8), to: try FileStorageRelativePath("b.txt"), options: .default)
        try await storage.write(Data("a".utf8), to: try FileStorageRelativePath("folder", "a.txt"), options: .default)

        let entries = try await storage.listFiles(recursive: true)
        XCTAssertEqual(entries.map { $0.relativePath.pathString }, ["b.txt", "folder/a.txt"])
    }

    func testTotalSizeSumsFiles() async throws {
        let (storage, _) = makeStorage()
        try await storage.write(Data("abc".utf8), to: try FileStorageRelativePath("a.txt"), options: .default)
        try await storage.write(Data("de".utf8), to: try FileStorageRelativePath("b.txt"), options: .default)

        let size = try await storage.totalSizeInBytes()
        XCTAssertEqual(size, 5)
    }

    func testCleanupRemovesMatchingFiles() async throws {
        let (storage, _) = makeStorage()
        try await storage.write(Data("abc".utf8), to: try FileStorageRelativePath("a.cache"), options: .default)
        try await storage.write(Data("de".utf8), to: try FileStorageRelativePath("b.keep"), options: .default)

        let result = try await storage.cleanup(policy: FileStorageCleanupPolicy(allowedFileExtensions: ["cache"]), now: Date())
        XCTAssertEqual(result.removedFileCount, 1)
        XCTAssertEqual(result.removedBytes, 3)
        let removedCacheExists = await storage.exists(try FileStorageRelativePath("a.cache"))
        let keptFileExists = await storage.exists(try FileStorageRelativePath("b.keep"))
        XCTAssertFalse(removedCacheExists)
        XCTAssertTrue(keptFileExists)
    }

    func testCleanupWithMaximumAgeKeepsFreshFile() async throws {
        let (storage, _) = makeStorage()
        try await storage.write(Data("abc".utf8), to: try FileStorageRelativePath("fresh.cache"), options: .default)

        let result = try await storage.cleanup(policy: FileStorageCleanupPolicy(maximumAge: 3600), now: Date())
        XCTAssertEqual(result.removedFileCount, 0)
        let freshFileExists = await storage.exists(try FileStorageRelativePath("fresh.cache"))
        XCTAssertTrue(freshFileExists)
    }

    func testDiagnosticsArePrivacySafeAndCountFiles() async throws {
        let (storage, _) = makeStorage()
        try await storage.write(Data("abc".utf8), to: try FileStorageRelativePath("secret-name.txt"), options: .default)

        let diagnostics = try await storage.diagnostics()
        XCTAssertEqual(diagnostics.fileCount, 1)
        XCTAssertEqual(diagnostics.totalSizeInBytes, 3)
        XCTAssertFalse(diagnostics.description.contains("secret-name"))
    }

    func testRemoveAllDeletesStorageDirectoryContents() async throws {
        let (storage, _) = makeStorage()
        let path = try FileStorageRelativePath("file.txt")
        try await storage.write(Data("abc".utf8), to: path, options: .default)
        try await storage.removeAll()
        let existsAfterRemoveAll = await storage.exists(path)
        XCTAssertFalse(existsAfterRemoveAll)
    }

    func testDescriptionsRedactNamespaceAndPath() throws {
        let namespace = FileStorageNamespace("auth-user-files")
        let path = try FileStorageRelativePath("private", "token.txt")
        XCTAssertFalse(namespace.description.contains("auth-user-files"))
        XCTAssertFalse(path.description.contains("token"))
    }

    func testStaticDirectoryProviderUsesSafeNamespacePath() throws {
        let base = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let provider = StaticFileStorageDirectoryProvider(baseURL: base)
        let directory = try provider.directory(for: .custom(FileStorageNamespace("custom root")), namespace: FileStorageNamespace("user files"))
        XCTAssertTrue(directory.url.path.contains("custom-root"))
        XCTAssertTrue(directory.url.path.contains("user-files"))
        XCTAssertFalse(directory.description.contains(directory.url.path))
    }

    func testReadRejectsSymlinkEscapingStorageRoot() async throws {
        let (storage, base) = makeStorage()
        let directory = base
            .appendingPathComponent("test-root", isDirectory: true)
            .appendingPathComponent("suite", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let outsideDirectory = base.appendingPathComponent("outside", isDirectory: true)
        try FileManager.default.createDirectory(at: outsideDirectory, withIntermediateDirectories: true)
        let outsideFile = outsideDirectory.appendingPathComponent("secret.txt", isDirectory: false)
        try Data("secret".utf8).write(to: outsideFile)
        let symlink = directory.appendingPathComponent("link.txt", isDirectory: false)
        try FileManager.default.createSymbolicLink(at: symlink, withDestinationURL: outsideFile)

        do {
            _ = try await storage.read(from: try FileStorageRelativePath("link.txt"), options: .default)
            XCTFail("Expected symlink escape to be rejected")
        } catch let error as FileStorageError {
            XCTAssertEqual(error, .invalidRelativePath(reason: .directoryTraversal))
        }
    }
}
