import XCTest
@testable import AppFeatureFlags

final class FeatureFlagBucketerTests: XCTestCase {
    func testBucketIsStableAndWithinRange() {
        let bucketer = StableFeatureFlagBucketer()
        let first = bucketer.bucket(key: "feature.a", identifier: "user-1")
        let second = bucketer.bucket(key: "feature.a", identifier: "user-1")

        XCTAssertEqual(first, second)
        XCTAssertGreaterThanOrEqual(first, 0)
        XCTAssertLessThan(first, 100)
    }

    func testDifferentIdentifiersUsuallyProduceDifferentBuckets() {
        let bucketer = StableFeatureFlagBucketer()
        XCTAssertNotEqual(
            bucketer.bucket(key: "feature.a", identifier: "user-1"),
            bucketer.bucket(key: "feature.a", identifier: "user-2")
        )
    }
}
