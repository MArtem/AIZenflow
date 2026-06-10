import XCTest
@testable import AppLogging

final class DefaultLogFormatterTests: XCTestCase {
    func testFormatIsStableAndPrivacySafe() {
        let formatter = DefaultLogFormatter()
        let event = LogEvent(
            timestamp: Date(timeIntervalSince1970: 0),
            level: .error,
            subsystem: "sync",
            category: "pull",
            message: "Failed",
            metadata: LogMetadata([
                "attempt": .integer(3),
                "refresh_token": .string("secret"),
                "endpoint": .url("https://api.example.com/items?secret=yes")
            ])
        )

        let result = formatter.format(event, redactor: .default)

        XCTAssertTrue(result.contains("[ERROR] sync.pull: Failed"))
        XCTAssertTrue(result.contains("attempt=3"))
        XCTAssertTrue(result.contains("refresh_token=<redacted>"))
        XCTAssertTrue(result.contains("endpoint=https://api.example.com/items"))
        XCTAssertFalse(result.contains("secret=yes"))
    }
}

extension DefaultLogFormatterTests {
    func testPrivateMessageIsNotRendered() {
        let formatter = DefaultLogFormatter()
        let event = LogEvent(
            timestamp: Date(timeIntervalSince1970: 0),
            level: .info,
            subsystem: "test",
            category: "privacy",
            message: "token=secret",
            messagePrivacy: .private
        )

        let rendered = formatter.format(event, redactor: .default)
        XCTAssertFalse(rendered.contains("token=secret"))
        XCTAssertTrue(rendered.contains("<private>"))
    }
}
