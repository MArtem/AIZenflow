import Foundation
import TchopLocalization

/// Central app-level localization facade used by views, models, and view models.
enum AppLocalization {
    private static let manager = LocalizationManager()

    /// Resolves plain localized text using resource values only.
    static func text(_ key: String) -> String {
        manager.localized(key, localeIdentifier: nil)
    }

    /// Resolves plain localized text.
    static func text(_ key: String, fallback: String) -> String {
        manager.localized(key, fallback: fallback, localeIdentifier: nil)
    }

    /// Resolves localized format text using resource values only.
    static func text(_ key: String, _ arguments: CVarArg...) -> String {
        manager.localized(
            key,
            arguments: arguments,
            localeIdentifier: nil
        )
    }

    /// Resolves localized format text and applies arguments.
    static func text(_ key: String, fallback: String, _ arguments: CVarArg...) -> String {
        manager.localized(
            key,
            fallback: fallback,
            arguments: arguments,
            localeIdentifier: nil
        )
    }
}
