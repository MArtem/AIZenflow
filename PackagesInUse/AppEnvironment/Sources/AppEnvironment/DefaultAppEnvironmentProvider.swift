import Foundation

public struct DefaultAppEnvironmentProvider: AppEnvironmentProviding {
    private let environmentKind: EnvironmentKind
    private let buildInfoProvider: any AppBuildInfoProviding
    private let runtimeFlagsProvider: any AppRuntimeFlagsProviding
    private let localeContextProvider: any AppLocaleContextProviding
    private let dateProvider: @Sendable () -> Date

    public init(
        environmentKind: EnvironmentKind,
        buildInfoProvider: any AppBuildInfoProviding = BundleAppBuildInfoProvider(),
        runtimeFlagsProvider: any AppRuntimeFlagsProviding = ProcessRuntimeFlagsProvider(),
        localeContextProvider: any AppLocaleContextProviding = CurrentLocaleContextProvider(),
        dateProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.environmentKind = environmentKind
        self.buildInfoProvider = buildInfoProvider
        self.runtimeFlagsProvider = runtimeFlagsProvider
        self.localeContextProvider = localeContextProvider
        self.dateProvider = dateProvider
    }

    public init(
        environmentVariableName: String = "APP_ENVIRONMENT",
        processEnvironment: [String: String] = ProcessInfo.processInfo.environment,
        buildInfoProvider: any AppBuildInfoProviding = BundleAppBuildInfoProvider(),
        runtimeFlagsProvider: any AppRuntimeFlagsProviding = ProcessRuntimeFlagsProvider(),
        localeContextProvider: any AppLocaleContextProviding = CurrentLocaleContextProvider(),
        dateProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.init(
            environmentKind: EnvironmentKind(rawValue: processEnvironment[environmentVariableName]),
            buildInfoProvider: buildInfoProvider,
            runtimeFlagsProvider: runtimeFlagsProvider,
            localeContextProvider: localeContextProvider,
            dateProvider: dateProvider
        )
    }

    public func snapshot() async -> AppEnvironmentSnapshot {
        let buildInfo = await buildInfoProvider.buildInfo()
        let runtimeFlags = await runtimeFlagsProvider.runtimeFlags()
        let localeContext = await localeContextProvider.localeContext()

        return AppEnvironmentSnapshot(
            kind: environmentKind,
            buildInfo: buildInfo,
            runtimeFlags: runtimeFlags,
            localeContext: localeContext,
            generatedAt: dateProvider()
        )
    }
}
