import Foundation
import TchopLocalization

/// App-specific localization resource bundle for Tchop runtime targets.
///
/// Ownership:
/// This target intentionally owns Tchop product strings. The reusable `TchopLocalization`
/// target owns only lookup/fallback mechanics and must not contain app copy.
public enum TchopAppLocalizationResources {
    /// Creates a localization manager backed by this target's resource bundle.
    public static func makeManager(
        tableName: String = "Localizable",
        developmentLanguageIdentifier: String = "en"
    ) -> LocalizationManager {
        LocalizationManager(
            tableName: tableName,
            developmentLanguageIdentifier: developmentLanguageIdentifier,
            bundleProvider: { .module }
        )
    }
}
