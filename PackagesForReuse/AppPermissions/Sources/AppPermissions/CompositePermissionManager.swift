import Foundation

/// Routes permission requests to permission-specific providers without coupling providers together.
public actor CompositePermissionManager: PermissionManaging {
    private let providersByKind: [PermissionKind: any PermissionProviding]

    public init(providers: [any PermissionProviding]) {
        var providersByKind: [PermissionKind: any PermissionProviding] = [:]
        for provider in providers {
            for kind in provider.supportedKinds {
                providersByKind[kind] = provider
            }
        }
        self.providersByKind = providersByKind
    }

    public func state(for kind: PermissionKind) async -> PermissionState {
        guard let provider = providersByKind[kind] else { return .unavailable }
        return await provider.state(for: kind)
    }

    public func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome {
        guard let provider = providersByKind[kind] else { throw PermissionError.unsupportedKind(kind) }
        return try await provider.request(kind)
    }
}
