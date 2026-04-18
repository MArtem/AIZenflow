import Foundation

/// Root snapshot describing server-driven UI configuration for the app shell.
public struct UIConfigurationSnapshot: Equatable, Sendable {
    public let shell: ShellUIConfiguration

    public init(shell: ShellUIConfiguration) {
        self.shell = shell
    }
}

/// Shell-scoped UI toggles that can be modified by remote configuration.
public struct ShellUIConfiguration: Equatable, Sendable {
    public let showsFloatingActionButton: Bool

    public init(showsFloatingActionButton: Bool) {
        self.showsFloatingActionButton = showsFloatingActionButton
    }
}

/// Contract for a remote source that fetches UI configuration from backend.
public protocol UIConfigurationRemoteProviding: Sendable {
    func fetchConfiguration() async throws -> UIConfigurationSnapshot
}

/// App-facing contract that can serve the active UI configuration snapshot.
public protocol UIConfigurationManaging: Sendable {
    func fetchConfiguration() async throws -> UIConfigurationSnapshot
}

/// Thin reusable manager that fronts a remote provider.
public struct UIConfigurationManager: UIConfigurationManaging {
    private let remoteProvider: any UIConfigurationRemoteProviding

    public init(remoteProvider: any UIConfigurationRemoteProviding) {
        self.remoteProvider = remoteProvider
    }

    public func fetchConfiguration() async throws -> UIConfigurationSnapshot {
        try await remoteProvider.fetchConfiguration()
    }
}

/// Mock remote source used until a real backend contract exists.
public struct MockUIConfigurationRemoteProvider: UIConfigurationRemoteProviding {
    private let response: UIConfigurationSnapshot
    private let delayNanoseconds: UInt64

    public init(
        response: UIConfigurationSnapshot = UIConfigurationSnapshot(
            shell: ShellUIConfiguration(showsFloatingActionButton: true)
        ),
        delayNanoseconds: UInt64 = 120_000_000
    ) {
        self.response = response
        self.delayNanoseconds = delayNanoseconds
    }

    public func fetchConfiguration() async throws -> UIConfigurationSnapshot {
        try await Task.sleep(nanoseconds: delayNanoseconds)
        try Task.checkCancellation()
        return response
    }
}
