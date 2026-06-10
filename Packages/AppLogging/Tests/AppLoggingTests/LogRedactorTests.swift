import XCTest
@testable import AppLogging

final class LogRedactorTests: XCTestCase {
    func testRedactsSensitiveKeys() {
        let metadata = LogMetadata([
            "access_token": .string("secret-token"),
            "user_id": .string("user-1")
        ])

        let redacted = metadata.redacted()

        XCTAssertEqual(redacted["access_token"], "<redacted>")
        XCTAssertEqual(redacted["user_id"], "user-1")
    }

    func testExplicitPrivatePrivacyWins() {
        let metadata = LogMetadata([
            "email": .string("person@example.com", privacy: .private),
            "phone": .string("+380000000000", privacy: .sensitive(mask: "<phone>"))
        ])

        XCTAssertEqual(metadata.redacted()["email"], "<private>")
        XCTAssertEqual(metadata.redacted()["phone"], "<phone>")
    }

    func testURLQueryAndFragmentAreRemoved() {
        let metadata = LogMetadata([
            "url": .url("https://example.com/path?token=secret#fragment")
        ])

        XCTAssertEqual(metadata.redacted()["url"], "https://example.com/path")
    }

    func testStringMasksAreApplied() {
        let redactor = LogRedactor(stringMasks: ["secret": "<masked>"])
        XCTAssertEqual(redactor.redactString("value-secret"), "value-<masked>")
    }
}
