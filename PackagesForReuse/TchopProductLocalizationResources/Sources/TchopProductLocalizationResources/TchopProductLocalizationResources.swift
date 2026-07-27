import Foundation

/// App-specific localization resource bundle for TchopApp runtime targets.
///
/// Ownership:
/// This target intentionally owns TchopApp product strings. It is now 100% single-folder
/// standalone: callers can either use `bundle` directly or add the optional
/// `TchopProductLocalizationResourcesAppLocalizationIntegration.swift` helper when
/// `AppLocalization` is also present in the host project.
public enum TchopProductLocalizationResources {
    /// Resource bundle that contains this target's localized product strings.
    public static var bundle: Bundle {
        .module
    }

    /// Looks up one localized product string directly from this target's bundle.
    ///
    /// This method is intentionally minimal. Reusable localization behavior such as locale resolution,
    /// fallback policies, and formatting can be provided by `AppLocalization` through the optional
    /// integration helper, without making this package depend on a sibling package.
    public static func localized(
        _ key: String,
        tableName: String = "Localizable",
        localeIdentifier: String? = nil,
        fallback: String? = nil
    ) -> String {
        let lookupBundle = localeIdentifier.flatMap { localizedBundle(for: $0) } ?? bundle
        let value = lookupBundle.localizedString(forKey: key, value: fallback, table: tableName)

        if value == key, let fallback {
            return fallback
        }

        return value
    }

    private static func localizedBundle(for localeIdentifier: String) -> Bundle? {
        let normalizedIdentifier = Locale(identifier: localeIdentifier).identifier
        let candidates = [
            normalizedIdentifier,
            Locale(identifier: normalizedIdentifier).language.languageCode?.identifier
        ].compactMap { $0 }

        for candidate in candidates {
            if let path = bundle.path(forResource: candidate, ofType: "lproj"),
               let localizedBundle = Bundle(path: path) {
                return localizedBundle
            }
        }

        return nil
    }
}
