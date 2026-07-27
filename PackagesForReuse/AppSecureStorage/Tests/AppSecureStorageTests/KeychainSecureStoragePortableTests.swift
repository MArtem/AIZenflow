import XCTest
@testable import AppSecureStorage

final class KeychainSecureStoragePortableTests: XCTestCase {
    func test_keychainTypeIsAvailableForDependencyInjection() {
        let storage = KeychainSecureStorage(service: "com.example.test")
        XCTAssertNotNil(storage)
    }

    #if !canImport(Security)
    func test_keychainPlaceholderThrowsUnsupportedPlatformWhenSecurityIsUnavailable() async throws {
        let storage = KeychainSecureStorage(service: "com.example.test")

        do {
            _ = try await storage.data(for: "key")
            XCTFail("Expected unsupported platform")
        } catch let error as SecureStorageError {
            XCTAssertEqual(error, .unsupportedPlatform)
        }
    }
    #endif
}
