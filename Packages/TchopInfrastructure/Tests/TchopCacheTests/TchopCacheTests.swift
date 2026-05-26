import XCTest
@testable import TchopCache

/// Verifies local cache manager behavior for memory and file backends.
final class TchopCacheTests: XCTestCase {
    /// Verifies in memory cache stores and reads value.
    func testInMemoryCacheStoresAndReadsValue() async throws {
        let cache = InMemoryLocalCacheManager()

        try await cache.setValue("value-1", forKey: "key-1", expiration: .never)
        let value: String? = try await cache.value(forKey: "key-1", as: String.self)

        XCTAssertEqual(value, "value-1")
    }

    /// Verifies in memory cache expires value.
    func testInMemoryCacheExpiresValue() async throws {
        let cache = InMemoryLocalCacheManager(dateProvider: { Date(timeIntervalSince1970: 200) })

        try await cache.setValue(
            "value-1",
            forKey: "key-1",
            expiration: .at(Date(timeIntervalSince1970: 100))
        )
        let value: String? = try await cache.value(forKey: "key-1", as: String.self)

        XCTAssertNil(value)
    }

    /// Verifies file cache persists value across instances.
    func testFileCachePersistsValueAcrossInstances() async throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let firstCache = try FileLocalCacheManager(directoryURL: directory)
        try await firstCache.setValue(["a", "b"], forKey: "letters", expiration: .never)

        let secondCache = try FileLocalCacheManager(directoryURL: directory)
        let value: [String]? = try await secondCache.value(forKey: "letters", as: [String].self)

        XCTAssertEqual(value, ["a", "b"])
    }

    /// Verifies file cache remove and clear.
    func testFileCacheRemoveAndClear() async throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let cache = try FileLocalCacheManager(directoryURL: directory)
        try await cache.setValue(1, forKey: "one", expiration: .never)
        try await cache.setValue(2, forKey: "two", expiration: .never)

        try await cache.removeValue(forKey: "one")
        let removed: Int? = try await cache.value(forKey: "one", as: Int.self)
        XCTAssertNil(removed)

        try await cache.clear()
        let remaining: Int? = try await cache.value(forKey: "two", as: Int.self)
        XCTAssertNil(remaining)
    }

    /// Verifies cache reports deserialization failures when callers request the wrong value type.
    func testCacheReportsDeserializationFailureForWrongRequestedType() async throws {
        let cache = InMemoryLocalCacheManager()

        try await cache.setValue("value", forKey: "key", expiration: .never)

        do {
            let _: Int? = try await cache.value(forKey: "key", as: Int.self)
            XCTFail("Expected deserialization failure")
        } catch let error as LocalCacheError {
            XCTAssertEqual(error, .deserializationFailed)
        }
    }

    /// Verifies expired file cache entries are removed from disk after read.
    func testFileCacheExpiresAndDeletesStoredEntry() async throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let cache = try FileLocalCacheManager(
            directoryURL: directory,
            dateProvider: { Date(timeIntervalSince1970: 200) }
        )

        try await cache.setValue(
            "expired",
            forKey: "expired-key",
            expiration: .at(Date(timeIntervalSince1970: 100))
        )
        XCTAssertEqual(try cacheFileCount(in: directory), 1)

        let value: String? = try await cache.value(forKey: "expired-key", as: String.self)

        XCTAssertNil(value)
        XCTAssertEqual(try cacheFileCount(in: directory), 0)
    }

    /// Verifies cache rejects empty key.
    func testCacheRejectsEmptyKey() async throws {
        let cache = InMemoryLocalCacheManager()

        do {
            try await cache.setValue("value", forKey: "   ", expiration: .never)
            XCTFail("Expected invalidKey error")
        } catch let error as LocalCacheError {
            XCTAssertEqual(error, .invalidKey)
        }
    }

    /// Creates temporary directory.
    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    /// Counts cache files in a temporary cache directory.
    private func cacheFileCount(in directory: URL) throws -> Int {
        try FileManager.default
            .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "cache" }
            .count
    }
}
