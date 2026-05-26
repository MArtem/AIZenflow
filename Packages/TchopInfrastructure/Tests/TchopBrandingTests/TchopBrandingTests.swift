import XCTest
@testable import TchopBranding

/// Verifies brand theme selection and token behavior.
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

    /// Verifies unknown info dictionary values fall back to the stable default variant.
    func testInfoDictionaryRejectsUnknownVariant() {
        let manager = InfoDictionaryBrandThemeManager(
            infoDictionary: [BrandThemeInfoKey.variant: "unknown"]
        )

        XCTAssertEqual(manager.activeVariant, .classic)
        XCTAssertEqual(manager.activeTheme.variant, .classic)
    }

    /// Verifies glass themes expose only registered semantic roles.
    func testGlassThemeResolvesRegisteredRolesOnly() {
        let theme = InfoDictionaryBrandThemeManager.theme(for: .classic)

        XCTAssertNotNil(theme.glass.style(for: .floatingActionButton))
        XCTAssertNil(theme.glass.style(for: BrandGlassRole(rawValue: "unknown.role")))
    }
}
