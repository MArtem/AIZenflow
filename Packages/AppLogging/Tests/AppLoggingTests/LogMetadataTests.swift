import XCTest
@testable import AppLogging

final class LogMetadataTests: XCTestCase {
    func testMergingUsesNewValues() {
        let first = LogMetadata(["a": .string("1"), "b": .string("old")])
        let second = LogMetadata(["b": .string("new"), "c": .integer(3)])

        let merged = first.merging(second)

        XCTAssertEqual(merged.values["a"], .string("1"))
        XCTAssertEqual(merged.values["b"], .string("new"))
        XCTAssertEqual(merged.values["c"], .integer(3))
    }

    func testCodableRoundtrip() throws {
        let metadata = LogMetadata([
            "string": .string("value"),
            "int": .integer(7),
            "bool": .bool(true),
            "array": .stringArray(["a", "b"], privacy: .private)
        ])

        let data = try JSONEncoder().encode(metadata)
        let decoded = try JSONDecoder().decode(LogMetadata.self, from: data)

        XCTAssertEqual(decoded, metadata)
    }
}
