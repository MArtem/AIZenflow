import XCTest
@testable import TchopLocalization

/// Validates localization manager lookup and formatting behavior.
final class TchopLocalizationTests: XCTestCase {
    func testLocalizedReturnsEnglishValueForExplicitLocale() {
        let manager = LocalizationManager()

        let value = manager.localized(
            "login.title",
            fallback: "Sign in",
            localeIdentifier: "en"
        )

        XCTAssertEqual(value, "Sign in")
    }

    func testLocalizedReturnsRussianValueForExplicitLocale() {
        let manager = LocalizationManager()

        let value = manager.localized(
            "login.title",
            fallback: "Sign in",
            localeIdentifier: "ru"
        )

        XCTAssertEqual(value, "Вход")
    }

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

