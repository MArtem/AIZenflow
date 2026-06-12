import Foundation

/// Immutable permission manager for tests and preview/static environments.
public struct StaticPermissionManager: PermissionManaging, PermissionProviding, Sendable {
    public let supportedKinds: Set<PermissionKind>
    private let states: [PermissionKind: PermissionState]
    private let defaultState: PermissionState

    public init(
        supportedKinds: Set<PermissionKind> = [],
        states: [PermissionKind: PermissionState] = [:],
        defaultState: PermissionState = .unavailable
    ) {
        self.supportedKinds = supportedKinds.isEmpty ? Set(states.keys) : supportedKinds
        self.states = states
        self.defaultState = defaultState
    }

    public func state(for kind: PermissionKind) async -> PermissionState {
        guard supportedKinds.isEmpty || supportedKinds.contains(kind) else { return .unavailable }
        return states[kind] ?? defaultState
    }

    public func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome {
        guard supportedKinds.isEmpty || supportedKinds.contains(kind) else {
            throw PermissionError.unsupportedKind(kind)
        }
        let state = states[kind] ?? defaultState
        guard state.canPromptUser else {
            if state.grantsAccess {
                return PermissionRequestOutcome(kind: kind, state: state, didPromptUser: false)
            }
            throw PermissionError.denied(kind, state: state)
        }
        return PermissionRequestOutcome(kind: kind, state: state, didPromptUser: false)
    }
}
