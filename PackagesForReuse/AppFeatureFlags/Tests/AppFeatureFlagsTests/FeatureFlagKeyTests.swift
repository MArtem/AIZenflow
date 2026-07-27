import XCTest
@testable import AppFeatureFlags

final class FeatureFlagKeyTests: XCTestCase {
    func testNamespaceInitializerBuildsStableKey() {
        XCTAssertEqual(FeatureFlagKey(namespace: "feed", name: "new-card").rawValue, "feed.new-card")
    }

    func testStringLiteralInitializer() {
        let key: FeatureFlagKey = "profile.edit"
        XCTAssertEqual(key.rawValue, "profile.edit")
    }

    func testTrimsWhitespace() {
        XCTAssertEqual(FeatureFlagKey(rawValue: "  flag  ").rawValue, "flag")
    }
}
