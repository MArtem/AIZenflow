import XCTest
@testable import AppSecureStorage

private struct Credentials: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
}

final class SecureStorageCodableTests: XCTestCase {
    func test_saveAndLoadCodableValue() async throws {
        let storage = InMemorySecureStorage()
        let credentials = Credentials(accessToken: "access", refreshToken: "refresh")

        try await storage.save(credentials, for: "credentials")
        let loaded = try await storage.value(for: "credentials", as: Credentials.self)

        XCTAssertEqual(loaded, credentials)
    }

    func test_loadingMissingCodableValueReturnsNil() async throws {
        let storage = InMemorySecureStorage()

        let loaded = try await storage.value(for: "missing", as: Credentials.self)

        XCTAssertNil(loaded)
    }

    func test_invalidCodablePayloadThrowsDecodingFailed() async throws {
        let storage = InMemorySecureStorage()
        try await storage.save(Data("not-json".utf8), for: "credentials")

        do {
            _ = try await storage.value(for: "credentials", as: Credentials.self)
            XCTFail("Expected decoding failure")
        } catch let error as SecureStorageError {
            XCTAssertEqual(error, .decodingFailed)
        }
    }
}
