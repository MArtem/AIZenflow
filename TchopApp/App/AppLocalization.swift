import Foundation
import TchopLocalization
import TchopAppLocalizationResources

/// Central app-level localization facade used by views, models, and view models.
enum AppLocalization {
    private static let manager = TchopAppLocalizationResources.makeManager()

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

    static var supportedLocaleIdentifiers: [String] {
        manager.supportedLocaleIdentifiers
    }

    static var preferredLocaleIdentifier: String {
        manager.preferredSupportedLocaleIdentifier()
    }

    static func displayName(for localeIdentifier: String) -> String {
        let preferredLocale = NSLocale(localeIdentifier: preferredLocaleIdentifier)
        return preferredLocale.displayName(forKey: .identifier, value: localeIdentifier) ?? localeIdentifier
    }
}
