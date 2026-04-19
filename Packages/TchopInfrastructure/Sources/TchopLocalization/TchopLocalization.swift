import Foundation

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
    private let bundleProvider: @Sendable () -> Bundle

    /// Creates a localization manager using package resource bundle.
    public init(tableName: String = "Localizable") {
        self.tableName = tableName
        self.bundleProvider = { .module }
    }

    /// Creates a localization manager with a custom bundle resolver.
    public init(
        tableName: String = "Localizable",
        bundleProvider: @escaping @Sendable () -> Bundle
    ) {
        self.tableName = tableName
        self.bundleProvider = bundleProvider
    }

    /// Resolves this operation.
    public func localized(_ key: String, fallback: String, localeIdentifier: String? = nil) -> String {
        let bundle = resolvedBundle(localeIdentifier: localeIdentifier)
        return NSLocalizedString(
            key,
            tableName: tableName,
            bundle: bundle,
            value: fallback,
            comment: ""
        )
    }

    /// Resolves this operation.
    public func localized(
        _ key: String,
        fallback: String,
        arguments: [CVarArg],
        localeIdentifier: String? = nil
    ) -> String {
        let format = localized(
            key,
            fallback: fallback,
            localeIdentifier: localeIdentifier
        )
        let locale = localeIdentifier.map(Locale.init(identifier:)) ?? .current
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
}
