import XCTest
@testable import TchopLocalization

/// Validates localization manager lookup and formatting behavior.
final class TchopLocalizationTests: XCTestCase {
    /// Verifies localized returns english value for explicit locale.
    func testLocalizedReturnsEnglishValueForExplicitLocale() {
        let manager = LocalizationManager()

        let value = manager.localized(
            "localization.test.title",
            fallback: "Sign in",
            localeIdentifier: "en"
        )

        XCTAssertEqual(value, "Localized title")
    }

    /// Verifies localized returns russian value for explicit locale.
    func testLocalizedReturnsRussianValueForExplicitLocale() {
        let manager = LocalizationManager()

        let value = manager.localized(
            "localization.test.title",
            fallback: "Sign in",
            localeIdentifier: "ru"
        )

        XCTAssertEqual(value, "Локализованный заголовок")
    }

    /// Verifies localized formats arguments.
    func testLocalizedFormatsArguments() {
        let manager = LocalizationManager()

        let value = manager.localized(
            "localization.test.format",
            fallback: "%@ fallback",
            arguments: ["Preview"],
            localeIdentifier: "en"
        )

        XCTAssertEqual(value, "Preview localized value")
    }

    /// Verifies unsupported explicit locale falls back to development language before caller fallback.
    func testLocalizedFallsBackToDevelopmentLanguageForUnsupportedLocale() {
        let manager = LocalizationManager()

        let value = manager.localized(
            "localization.test.title",
            fallback: "Sign in",
            localeIdentifier: "uk"
        )

        XCTAssertEqual(value, "Localized title")
    }

    /// Verifies missing keys use the caller fallback value.
    func testLocalizedUsesCallerFallbackForMissingKey() {
        let manager = LocalizationManager()

        let value = manager.localized(
            "missing.key",
            fallback: "Fallback",
            localeIdentifier: "en"
        )

        XCTAssertEqual(value, "Fallback")
    }

    /// Verifies preferred locale resolves exact and language-code matches before defaulting.
    func testPreferredSupportedLocaleIdentifierResolvesBestSupportedMatch() {
        let manager = LocalizationManager()

        XCTAssertEqual(
            manager.preferredSupportedLocaleIdentifier(preferredLocaleIdentifiers: ["ru-UA", "en-US"]),
            "ru"
        )
        XCTAssertEqual(
            manager.preferredSupportedLocaleIdentifier(preferredLocaleIdentifiers: ["fr-FR"]),
            "en"
        )
    }
}
