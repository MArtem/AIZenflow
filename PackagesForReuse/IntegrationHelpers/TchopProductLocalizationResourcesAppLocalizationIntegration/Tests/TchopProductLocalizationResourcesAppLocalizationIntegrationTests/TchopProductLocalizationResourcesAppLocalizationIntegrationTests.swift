import AppLocalization
import TchopProductLocalizationResources
import TchopProductLocalizationResourcesAppLocalizationIntegration
import XCTest

final class TchopProductLocalizationResourcesAppLocalizationIntegrationTests: XCTestCase {
    func testMakeManagerUsesProductBundle() {
        let manager = TchopProductLocalizationResources.makeManager()
        let value = manager.localized("channel.header.title", fallback: "fallback")
        XCTAssertNotEqual(value, "fallback")
    }
}
