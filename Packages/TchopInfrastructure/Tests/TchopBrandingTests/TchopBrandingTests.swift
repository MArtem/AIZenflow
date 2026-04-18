import XCTest
@testable import TchopBranding

final class TchopBrandingTests: XCTestCase {
    func testInfoDictionaryDefaultsToClassicVariant() {
        let manager = InfoDictionaryBrandThemeManager(infoDictionary: [:])

        XCTAssertEqual(manager.activeVariant, .classic)
        XCTAssertEqual(manager.activeTheme.variant, .classic)
    }

    func testInfoDictionaryResolvesOceanVariant() {
        let manager = InfoDictionaryBrandThemeManager(
            infoDictionary: [BrandThemeInfoKey.variant: BrandVariant.ocean.rawValue]
        )

        XCTAssertEqual(manager.activeVariant, .ocean)
        XCTAssertEqual(manager.activeTheme.variant, .ocean)
    }
}
