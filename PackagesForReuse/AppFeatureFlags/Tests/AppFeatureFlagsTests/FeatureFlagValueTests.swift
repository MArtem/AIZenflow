import XCTest
@testable import AppFeatureFlags

final class FeatureFlagValueTests: XCTestCase {
    func testCodableRoundTrip() throws {
        let values: [FeatureFlagValue] = [
            .bool(true), .string("a"), .int(1), .double(2.5), .stringArray(["a", "b"]), .null
        ]

        let data = try JSONEncoder().encode(values)
        let decoded = try JSONDecoder().decode([FeatureFlagValue].self, from: data)
        XCTAssertEqual(decoded, values)
    }

    func testTypedAccessors() {
        XCTAssertEqual(FeatureFlagValue.bool(true).boolValue, true)
        XCTAssertEqual(FeatureFlagValue.string("x").stringValue, "x")
        XCTAssertEqual(FeatureFlagValue.int(2).doubleValue, 2.0)
    }
}

extension FeatureFlagValueTests {
    func testDescriptionDoesNotExposeRawStringValues() {
        XCTAssertEqual(String(describing: FeatureFlagValue.string("https://example.com?token=secret")), "<string>")
        XCTAssertEqual(String(describing: FeatureFlagValue.stringArray(["one", "two"])), "<string_array:2>")
        XCTAssertEqual(FeatureFlagValue.string("visible").rawStringForDisplay, "visible")
    }
}
