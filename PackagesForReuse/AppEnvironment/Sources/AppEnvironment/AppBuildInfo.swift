import Foundation

/// Minimal app/build identity extracted from the host bundle.
///
/// This type stores only selected public build metadata. It never stores the
/// full bundle info dictionary because that can contain product-specific or
/// sensitive values.
public struct AppBuildInfo: Equatable, Sendable, Codable {
    public let bundleIdentifier: String?
    public let displayName: String?
    public let version: String?
    public let buildNumber: String?
    public let buildConfiguration: BuildConfiguration

    public init(
        bundleIdentifier: String? = nil,
        displayName: String? = nil,
        version: String? = nil,
        buildNumber: String? = nil,
        buildConfiguration: BuildConfiguration = .current
    ) {
        self.bundleIdentifier = AppBuildInfo.clean(bundleIdentifier)
        self.displayName = AppBuildInfo.clean(displayName)
        self.version = AppBuildInfo.clean(version)
        self.buildNumber = AppBuildInfo.clean(buildNumber)
        self.buildConfiguration = buildConfiguration
    }

    public var versionDisplay: String {
        switch (version, buildNumber) {
        case let (version?, build?):
            return "\(version) (\(build))"
        case let (version?, nil):
            return version
        case let (nil, build?):
            return build
        case (nil, nil):
            return "unknown"
        }
    }

    private static func clean(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension AppBuildInfo: CustomStringConvertible {
    public var description: String {
        "AppBuildInfo(version: \(versionDisplay), configuration: \(buildConfiguration.rawValue))"
    }
}
