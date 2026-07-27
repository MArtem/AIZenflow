import Foundation

/// Runtime flags useful for previews, tests and app composition roots.
public struct AppRuntimeFlags: Equatable, Sendable, Codable {
    public let isDebugBuild: Bool
    public let isSimulator: Bool
    public let isRunningTests: Bool
    public let isUITesting: Bool
    public let isPreview: Bool
    public let processName: String?

    public init(
        isDebugBuild: Bool,
        isSimulator: Bool,
        isRunningTests: Bool = false,
        isUITesting: Bool = false,
        isPreview: Bool = false,
        processName: String? = nil
    ) {
        self.isDebugBuild = isDebugBuild
        self.isSimulator = isSimulator
        self.isRunningTests = isRunningTests
        self.isUITesting = isUITesting
        self.isPreview = isPreview
        self.processName = AppRuntimeFlags.clean(processName)
    }

    public var isAutomation: Bool {
        isRunningTests || isUITesting || isPreview
    }

    private static func clean(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension AppRuntimeFlags: CustomStringConvertible {
    public var description: String {
        "AppRuntimeFlags(debug: \(isDebugBuild), simulator: \(isSimulator), automation: \(isAutomation))"
    }
}
