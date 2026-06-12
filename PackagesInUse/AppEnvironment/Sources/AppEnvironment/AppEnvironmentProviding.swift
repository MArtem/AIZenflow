import Foundation

public protocol AppBuildInfoProviding: Sendable {
    func buildInfo() async -> AppBuildInfo
}

public protocol AppRuntimeFlagsProviding: Sendable {
    func runtimeFlags() async -> AppRuntimeFlags
}

public protocol AppLocaleContextProviding: Sendable {
    func localeContext() async -> AppLocaleContext
}

public protocol AppEnvironmentProviding: Sendable {
    func snapshot() async -> AppEnvironmentSnapshot
}
