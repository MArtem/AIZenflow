import AppLocalization
import TchopProductLocalizationResources

/// Optional integration helper for projects that use both `TchopProductLocalizationResources` and `AppLocalization`.
///
/// Copy this file into the host app/integration target when both root packages are already present.
/// It intentionally lives outside both packages so each package remains single-folder standalone.
public extension TchopProductLocalizationResources {
    /// Creates a localization manager backed by this target's resource bundle.
    static func makeManager(
        tableName: String = "Localizable",
        developmentLanguageIdentifier: String = "en"
    ) -> LocalizationManager {
        LocalizationManager(
            tableName: tableName,
            developmentLanguageIdentifier: developmentLanguageIdentifier,
            bundleProvider: { bundle }
        )
    }
}
