import Foundation

public struct ProcessRuntimeFlagsProvider: AppRuntimeFlagsProviding {
    private let environment: [String: String]
    private let arguments: [String]
    private let processName: String
    private let buildConfiguration: BuildConfiguration

    public init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        arguments: [String] = ProcessInfo.processInfo.arguments,
        processName: String = ProcessInfo.processInfo.processName,
        buildConfiguration: BuildConfiguration = .current
    ) {
        self.environment = environment
        self.arguments = arguments
        self.processName = processName
        self.buildConfiguration = buildConfiguration
    }

    public func runtimeFlags() async -> AppRuntimeFlags {
        Self.makeRuntimeFlags(
            environment: environment,
            arguments: arguments,
            processName: processName,
            buildConfiguration: buildConfiguration
        )
    }

    /// Resolves runtime flags synchronously for app entry points that cannot await during initialization.
    public static func makeRuntimeFlags(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        arguments: [String] = ProcessInfo.processInfo.arguments,
        processName: String = ProcessInfo.processInfo.processName,
        buildConfiguration: BuildConfiguration = .current
    ) -> AppRuntimeFlags {
        AppRuntimeFlags(
            isDebugBuild: buildConfiguration == .debug,
            isSimulator: isSimulator,
            isRunningTests: environment["XCTestConfigurationFilePath"] != nil,
            isUITesting: environment["UI_TESTING"] == "1" || arguments.contains("-UITesting"),
            isPreview: environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1",
            processName: processName
        )
    }

    private static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
