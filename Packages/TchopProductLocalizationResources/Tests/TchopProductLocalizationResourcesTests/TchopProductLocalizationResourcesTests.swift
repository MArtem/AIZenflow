import XCTest
@testable import TchopProductLocalizationResources

final class TchopProductLocalizationResourcesTests: XCTestCase {
    func testProductLocalizationBundleProvidesKnownAppString() {
        let manager = TchopProductLocalizationResources.makeManager()

        let title = manager.localized("login.title", localeIdentifier: "en")

        XCTAssertEqual(title, "Welcome back")
    }
}
