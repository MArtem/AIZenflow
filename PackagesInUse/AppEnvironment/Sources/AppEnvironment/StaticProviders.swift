import Foundation

public struct StaticAppBuildInfoProvider: AppBuildInfoProviding {
    private let value: AppBuildInfo

    public init(_ value: AppBuildInfo) {
        self.value = value
    }

    public func buildInfo() async -> AppBuildInfo {
        value
    }
}

public struct StaticRuntimeFlagsProvider: AppRuntimeFlagsProviding {
    private let value: AppRuntimeFlags

    public init(_ value: AppRuntimeFlags) {
        self.value = value
    }

    public func runtimeFlags() async -> AppRuntimeFlags {
        value
    }
}

public struct StaticLocaleContextProvider: AppLocaleContextProviding {
    private let value: AppLocaleContext

    public init(_ value: AppLocaleContext) {
        self.value = value
    }

    public func localeContext() async -> AppLocaleContext {
        value
    }
}

public struct StaticEnvironmentProvider: AppEnvironmentProviding {
    private let value: AppEnvironmentSnapshot

    public init(_ value: AppEnvironmentSnapshot) {
        self.value = value
    }

    public func snapshot() async -> AppEnvironmentSnapshot {
        value
    }
}
