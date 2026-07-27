import Foundation

/// Build info provider that extracts a small allowlist from a Bundle.
public struct BundleAppBuildInfoProvider: AppBuildInfoProviding {
    private let value: AppBuildInfo

    public init(bundle: Bundle = .main, buildConfiguration: BuildConfiguration = .current) {
        self.value = AppBuildInfo(
            bundleIdentifier: bundle.bundleIdentifier,
            displayName: BundleAppBuildInfoProvider.stringValue(for: "CFBundleDisplayName", in: bundle)
                ?? BundleAppBuildInfoProvider.stringValue(for: "CFBundleName", in: bundle),
            version: BundleAppBuildInfoProvider.stringValue(for: "CFBundleShortVersionString", in: bundle),
            buildNumber: BundleAppBuildInfoProvider.stringValue(for: "CFBundleVersion", in: bundle),
            buildConfiguration: buildConfiguration
        )
    }

    public func buildInfo() async -> AppBuildInfo {
        value
    }

    private static func stringValue(for key: String, in bundle: Bundle) -> String? {
        bundle.object(forInfoDictionaryKey: key) as? String
    }
}
