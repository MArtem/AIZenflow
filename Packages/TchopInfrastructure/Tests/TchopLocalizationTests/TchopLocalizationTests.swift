import XCTest
@testable import TchopLocalization

/// Validates localization manager lookup and formatting behavior.
final class TchopLocalizationTests: XCTestCase {
    /// Verifies localized returns english value for explicit locale.
    func testLocalizedReturnsEnglishValueForExplicitLocale() {
        let manager = LocalizationManager()

        let value = manager.localized(
            "login.title",
            fallback: "Sign in",
            localeIdentifier: "en"
        )

        XCTAssertEqual(value, "Sign in")
    }

    /// Verifies localized returns russian value for explicit locale.
    func testLocalizedReturnsRussianValueForExplicitLocale() {
        let manager = LocalizationManager()

        let value = manager.localized(
            "login.title",
            fallback: "Sign in",
            localeIdentifier: "ru"
        )

        XCTAssertEqual(value, "Вход")
    }

    /// Verifies localized formats arguments.
    func testLocalizedFormatsArguments() {
        let manager = LocalizationManager()

        let value = manager.localized(
            "mixes.route.quickAction.descriptionFormat",
            fallback: "%@ fallback",
            arguments: ["Preview"],
            localeIdentifier: "en"
        )

        XCTAssertTrue(value.hasPrefix("Preview."))
    }
}

