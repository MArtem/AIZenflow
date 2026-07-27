import Foundation

private final class AppLocalizationBundleToken {}

/// Contract for localization providers used by feature/UI layers.
public protocol LocalizationManaging: Sendable {
    /// Resolves localized string for the provided key and fallback value.
    func localized(_ key: String, fallback: String, localeIdentifier: String?) -> String

    /// Resolves localized format string and applies arguments with optional locale override.
    func localized(
        _ key: String,
        fallback: String,
        arguments: [CVarArg],
        localeIdentifier: String?
    ) -> String
}

/// Reusable localization manager backed by bundle resources.
public struct LocalizationManager: LocalizationManaging, Sendable {
    private let tableName: String
    private let developmentLanguageIdentifier: String
    private let bundleProvider: @Sendable () -> Bundle

    /// Creates a localization manager using package resource bundle.
    public init(tableName: String = "Localizable") {
        self.tableName = tableName
        self.developmentLanguageIdentifier = "en"
        self.bundleProvider = { Bundle(for: AppLocalizationBundleToken.self) }
    }

    /// Creates a localization manager with a custom bundle resolver.
    public init(
        tableName: String = "Localizable",
        developmentLanguageIdentifier: String = "en",
        bundleProvider: @escaping @Sendable () -> Bundle
    ) {
        self.tableName = tableName
        self.developmentLanguageIdentifier = developmentLanguageIdentifier
        self.bundleProvider = bundleProvider
    }

    /// Locale identifiers directly supported by the underlying localization bundle.
    public var supportedLocaleIdentifiers: [String] {
        bundleProvider()
            .localizations
            .filter { $0 != "Base" }
            .sorted()
    }

    /// Preferred locale identifier resolved against the bundle-supported locales.
    public func preferredSupportedLocaleIdentifier(
        preferredLocaleIdentifiers: [String] = Locale.preferredLanguages
    ) -> String {
        let supportedIdentifiers = supportedLocaleIdentifiers
        guard !supportedIdentifiers.isEmpty else {
            return developmentLanguageIdentifier
        }

        for preferredIdentifier in preferredLocaleIdentifiers {
            let locale = Locale(identifier: preferredIdentifier)
            let candidates = [
                locale.identifier(.bcp47),
                locale.language.languageCode?.identifier
            ]
            .compactMap { $0 }

            if let match = candidates.first(where: supportedIdentifiers.contains) {
                return match
            }
        }

        return supportedIdentifiers.contains(developmentLanguageIdentifier)
            ? developmentLanguageIdentifier
            : supportedIdentifiers[0]
    }

    /// Resolves a localized string by key and falls back to the development language bundle before returning the key itself.
    public func localized(_ key: String, localeIdentifier: String? = nil) -> String {
        if let resolvedValue = resolvedLocalizedValue(key, localeIdentifier: localeIdentifier) {
            return resolvedValue
        }

        assertionFailure("Missing localization value for key '\(key)'.")
        return key
    }

    /// Resolves a localized format string by key and applies arguments using the requested locale.
    public func localized(
        _ key: String,
        arguments: [CVarArg],
        localeIdentifier: String? = nil
    ) -> String {
        let format = localized(key, localeIdentifier: localeIdentifier)
        let locale = localeIdentifier.map(Locale.init(identifier:)) ?? .current
        return String(format: format, locale: locale, arguments: arguments)
    }

    /// Resolves this operation.
    public func localized(_ key: String, fallback: String, localeIdentifier: String? = nil) -> String {
        resolvedLocalizedValue(key, localeIdentifier: localeIdentifier) ?? fallback
    }

    /// Resolves this operation.
    public func localized(
        _ key: String,
        fallback: String,
        arguments: [CVarArg],
        localeIdentifier: String? = nil
    ) -> String {
        let locale = localeIdentifier.map(Locale.init(identifier:)) ?? .current
        guard let format = resolvedLocalizedValue(key, localeIdentifier: localeIdentifier) else {
            return String(format: fallback, locale: locale, arguments: arguments)
        }

        return String(format: format, locale: locale, arguments: arguments)
    }

    /// Handles resolved bundle.
    private func resolvedBundle(localeIdentifier: String?) -> Bundle {
        let bundle = bundleProvider()
        guard
            let localeIdentifier,
            let bundlePath = bundle.path(forResource: localeIdentifier, ofType: "lproj"),
            let localizedBundle = Bundle(path: bundlePath)
        else {
            return bundle
        }
        return localizedBundle
    }

    /// Resolves the development-language bundle used as a stable fallback when a translation is missing.
    private func developmentLanguageBundle() -> Bundle {
        let bundle = bundleProvider()
        guard
            let bundlePath = bundle.path(forResource: developmentLanguageIdentifier, ofType: "lproj"),
            let localizedBundle = Bundle(path: bundlePath)
        else {
            return bundle
        }
        return localizedBundle
    }

    /// Reads one localized value from a concrete bundle without silently substituting a fallback string.
    private func localizedValue(
        _ key: String,
        in bundle: Bundle,
        missingSentinel: String
    ) -> String {
        bundle.localizedString(
            forKey: key,
            value: missingSentinel,
            table: tableName
        )
    }

    /// Resolves one localized value without asserting, returning `nil` when neither active nor development bundle contain the key.
    private func resolvedLocalizedValue(_ key: String, localeIdentifier: String?) -> String? {
        let missingSentinel = "__missing__\(key)__"
        let resolvedLocalizedValue = localizedValue(
            key,
            in: resolvedBundle(localeIdentifier: localeIdentifier),
            missingSentinel: missingSentinel
        )

        if resolvedLocalizedValue != missingSentinel {
            return resolvedLocalizedValue
        }

        let developmentLanguageValue = localizedValue(
            key,
            in: developmentLanguageBundle(),
            missingSentinel: missingSentinel
        )

        return developmentLanguageValue == missingSentinel ? nil : developmentLanguageValue
    }
}
