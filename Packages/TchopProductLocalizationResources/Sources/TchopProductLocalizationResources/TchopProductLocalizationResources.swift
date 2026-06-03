import Foundation
import AppLocalization

/// App-specific localization resource bundle for TchopApp runtime targets.
///
/// Ownership:
/// This target intentionally owns TchopApp product strings. The reusable `AppLocalization`
/// target owns only lookup/fallback mechanics and must not contain app copy.
public enum TchopProductLocalizationResources {
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
