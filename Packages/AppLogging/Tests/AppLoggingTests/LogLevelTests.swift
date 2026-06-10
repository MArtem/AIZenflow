import XCTest
@testable import AppLogging

final class LogLevelTests: XCTestCase {
    func testOrdering() {
        XCTAssertLessThan(LogLevel.debug, .info)
        XCTAssertGreaterThan(LogLevel.critical, .error)
    }

    func testNamesAreStable() {
        XCTAssertEqual(LogLevel.trace.name, "trace")
        XCTAssertEqual(LogLevel.critical.name, "critical")
    }
}
