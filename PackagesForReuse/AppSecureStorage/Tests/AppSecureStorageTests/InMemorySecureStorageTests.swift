import XCTest
@testable import AppSecureStorage

final class InMemorySecureStorageTests: XCTestCase {
    func test_saveAndReadData() async throws {
        let storage = InMemorySecureStorage()
        let key = SecureStorageKey("test.token")
        let data = Data("secret".utf8)

        try await storage.save(data, for: key)

        let loaded = try await storage.data(for: key)
        XCTAssertEqual(loaded, data)
    }

    func test_missingValueReturnsNil() async throws {
        let storage = InMemorySecureStorage()

        let loaded = try await storage.data(for: "missing")

        XCTAssertNil(loaded)
    }

    func test_containsReflectsStoredValue() async throws {
        let storage = InMemorySecureStorage()
        let key = SecureStorageKey("exists")

        let containsBeforeSave = try await storage.contains(key)
        XCTAssertFalse(containsBeforeSave)

        try await storage.save(Data([1, 2, 3]), for: key)

        let containsAfterSave = try await storage.contains(key)
        XCTAssertTrue(containsAfterSave)
    }

    func test_removeValueDeletesOnlyRequestedKey() async throws {
        let storage = InMemorySecureStorage()
        try await storage.save(Data([1]), for: "a")
        try await storage.save(Data([2]), for: "b")

        try await storage.removeValue(for: "a")

        let removedValue = try await storage.data(for: "a")
        let remainingValue = try await storage.data(for: "b")
        XCTAssertNil(removedValue)
        XCTAssertEqual(remainingValue, Data([2]))
    }

    func test_removeAllDeletesEverything() async throws {
        let storage = InMemorySecureStorage()
        try await storage.save(Data([1]), for: "a")
        try await storage.save(Data([2]), for: "b")

        try await storage.removeAll()

        let keys = try await storage.keys()
        XCTAssertEqual(keys, [])
    }

    func test_keysAreSorted() async throws {
        let storage = InMemorySecureStorage()
        try await storage.save(Data([1]), for: "c")
        try await storage.save(Data([1]), for: "a")
        try await storage.save(Data([1]), for: "b")

        let keys = try await storage.keys().map(\.rawValue)

        XCTAssertEqual(keys, ["a", "b", "c"])
    }

    func test_recordContainsMetadata() async throws {
        let storage = InMemorySecureStorage()
        let data = Data([1, 2, 3, 4])
        try await storage.save(data, for: "record")

        let record = try await storage.record(for: "record")

        XCTAssertEqual(record?.data, data)
        XCTAssertEqual(record?.approximateSizeInBytes, 4)
        XCTAssertEqual(record?.key, "record")
    }

    func test_emptyKeyThrowsInvalidKey() async throws {
        let storage = InMemorySecureStorage()

        do {
            try await storage.save(Data([1]), for: "")
            XCTFail("Expected invalid key error")
        } catch let error as SecureStorageError {
            XCTAssertEqual(error, .invalidKey)
        }
    }

    func test_valueTooLargeThrows() async throws {
        let storage = InMemorySecureStorage(maximumValueSizeInBytes: 2)

        do {
            try await storage.save(Data([1, 2, 3]), for: "large")
            XCTFail("Expected valueTooLarge error")
        } catch let error as SecureStorageError {
            XCTAssertEqual(error, .valueTooLarge(maximumBytes: 2, actualBytes: 3))
        }
    }
}
