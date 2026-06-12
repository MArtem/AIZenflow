import Foundation

/// Privacy-safe environment diagnostics suitable for support screens or tests.
public struct AppEnvironmentDiagnostics: Equatable, Sendable, Codable {
    public let environmentCode: String
    public let buildConfiguration: String
    public let versionDisplay: String
    public let isSimulator: Bool
    public let isAutomation: Bool
    public let localeIdentifier: String
    public let timeZoneIdentifier: String

    public init(snapshot: AppEnvironmentSnapshot) {
        self.environmentCode = snapshot.kind.stableCode
        self.buildConfiguration = snapshot.buildInfo.buildConfiguration.rawValue
        self.versionDisplay = snapshot.buildInfo.versionDisplay
        self.isSimulator = snapshot.runtimeFlags.isSimulator
        self.isAutomation = snapshot.runtimeFlags.isAutomation
        self.localeIdentifier = snapshot.localeContext.localeIdentifier
        self.timeZoneIdentifier = snapshot.localeContext.timeZoneIdentifier
    }
}

extension AppEnvironmentDiagnostics: CustomStringConvertible {
    public var description: String {
        "AppEnvironmentDiagnostics(environment: \(environmentCode), build: \(versionDisplay), automation: \(isAutomation))"
    }
}
