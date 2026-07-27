import Foundation

/// Complete app-independent environment snapshot.
public struct AppEnvironmentSnapshot: Equatable, Sendable, Codable {
    public let kind: EnvironmentKind
    public let buildInfo: AppBuildInfo
    public let runtimeFlags: AppRuntimeFlags
    public let localeContext: AppLocaleContext
    public let generatedAt: Date

    public init(
        kind: EnvironmentKind,
        buildInfo: AppBuildInfo,
        runtimeFlags: AppRuntimeFlags,
        localeContext: AppLocaleContext,
        generatedAt: Date = Date()
    ) {
        self.kind = kind
        self.buildInfo = buildInfo
        self.runtimeFlags = runtimeFlags
        self.localeContext = localeContext
        self.generatedAt = generatedAt
    }

    public var isProduction: Bool {
        kind == .production
    }

    public var isAutomation: Bool {
        runtimeFlags.isAutomation
    }
}

extension AppEnvironmentSnapshot: CustomStringConvertible {
    public var description: String {
        "AppEnvironmentSnapshot(kind: \(kind.stableCode), build: \(buildInfo.versionDisplay), automation: \(isAutomation))"
    }
}
