import XCTest
@testable import AppSecureStorage

final class SecureStorageKeyTests: XCTestCase {
    func test_namespaceBuildsNamespacedKey() {
        let namespace = SecureStorageNamespace("auth")

        let key = namespace.key("token")

        XCTAssertEqual(key.rawValue, "auth.token")
    }

    func test_descriptionDoesNotExposeRawKey() {
        let key = SecureStorageKey("very-sensitive-token-key")

        let description = key.description

        XCTAssertEqual(description, "SecureStorageKey(<redacted>)")
        XCTAssertFalse(description.contains("very-sensitive-token-key"))
    }

    func test_descriptionDoesNotExposeStableHashLikeIdentifier() {
        let key = SecureStorageKey("auth.access-token")

        let description = key.description

        XCTAssertEqual(description, "SecureStorageKey(<redacted>)")
        XCTAssertFalse(description.contains("auth"))
        XCTAssertFalse(description.contains("access"))
        XCTAssertFalse(description.contains("token"))
    }

    func test_namespaceDescriptionDoesNotExposeRawValueOrStableHash() {
        let namespace = SecureStorageNamespace("private.namespace")

        let description = namespace.description

        XCTAssertEqual(description, "SecureStorageNamespace(<redacted>)")
        XCTAssertFalse(description.contains("private.namespace"))
    }

    func test_accessControlCreationFailureDescriptionIsSanitized() {
        let error = SecureStorageError.accessControlCreationFailed

        XCTAssertEqual(
            error.errorDescription,
            "Secure storage could not create the requested access-control policy."
        )
    }
}
