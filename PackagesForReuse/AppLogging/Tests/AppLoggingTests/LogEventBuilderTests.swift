import XCTest
@testable import AppLogging

final class LogEventBuilderTests: XCTestCase {
    func testBuildsEvent() {
        let timestamp = Date(timeIntervalSince1970: 100)
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

        let event = LogEventBuilder(level: .warning, message: "Something happened")
            .subsystem("networking")
            .category("retry")
            .metadata("attempt", .integer(2))
            .source(file: "File.swift", function: "test()", line: 10)
            .build(timestamp: timestamp, id: id)

        XCTAssertEqual(event.id, id)
        XCTAssertEqual(event.timestamp, timestamp)
        XCTAssertEqual(event.level, .warning)
        XCTAssertEqual(event.subsystem, "networking")
        XCTAssertEqual(event.category, "retry")
        XCTAssertEqual(event.message, "Something happened")
        XCTAssertEqual(event.metadata.values["attempt"], .integer(2))
        XCTAssertEqual(event.source?.line, 10)
    }
}
