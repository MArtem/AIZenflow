import XCTest
@testable import TchopBranding

final class TchopBrandingTests: XCTestCase {
    /// Verifies info dictionary defaults to classic variant.
    func testInfoDictionaryDefaultsToClassicVariant() {
        let manager = InfoDictionaryBrandThemeManager(infoDictionary: [:])

        XCTAssertEqual(manager.activeVariant, .classic)
        XCTAssertEqual(manager.activeTheme.variant, .classic)
    }

    /// Verifies info dictionary resolves ocean variant.
    func testInfoDictionaryResolvesOceanVariant() {
        let manager = InfoDictionaryBrandThemeManager(
            infoDictionary: [BrandThemeInfoKey.variant: BrandVariant.ocean.rawValue]
        )

        XCTAssertEqual(manager.activeVariant, .ocean)
        XCTAssertEqual(manager.activeTheme.variant, .ocean)
    }
}
