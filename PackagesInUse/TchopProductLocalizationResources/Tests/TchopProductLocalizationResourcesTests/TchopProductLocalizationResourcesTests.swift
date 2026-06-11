import XCTest
@testable import TchopProductLocalizationResources

final class TchopProductLocalizationResourcesTests: XCTestCase {
    func testProductLocalizationBundleProvidesKnownAppString() {
        let title = TchopProductLocalizationResources.localized("login.title", localeIdentifier: "en")

        XCTAssertEqual(title, "Welcome back")
    }

    func testProductLocalizationBundleSupportsLocaleSpecificLookup() {
        let title = TchopProductLocalizationResources.localized("login.title", localeIdentifier: "ru")

        XCTAssertFalse(title.isEmpty)
        XCTAssertNotEqual(title, "login.title")
    }
}
