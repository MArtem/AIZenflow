import Foundation
import TchopLocalization

/// Central app-level localization facade used by views, models, and view models.
enum AppLocalization {
    private static let manager: LocalizationManaging = LocalizationManager()

    /// Resolves plain localized text.
    static func text(_ key: String, fallback: String) -> String {
        manager.localized(key, fallback: fallback, localeIdentifier: nil)
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

