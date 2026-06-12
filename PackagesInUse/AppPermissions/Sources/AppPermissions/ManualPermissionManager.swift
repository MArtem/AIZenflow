import Foundation

/// In-memory manager for tests, previews, and deterministic host-app integration tests.
public actor ManualPermissionManager: PermissionManaging, PermissionProviding {
    public let supportedKinds: Set<PermissionKind>
    private let defaultState: PermissionState
    private var states: [PermissionKind: PermissionState]
    private var requestOutcomes: [PermissionKind: PermissionRequestOutcome]

    public init(
        supportedKinds: Set<PermissionKind> = [],
        defaultState: PermissionState = .notDetermined,
        states: [PermissionKind: PermissionState] = [:],
        requestOutcomes: [PermissionKind: PermissionRequestOutcome] = [:]
    ) {
        self.supportedKinds = supportedKinds.isEmpty ? Set(states.keys).union(requestOutcomes.keys) : supportedKinds
        self.defaultState = defaultState
        self.states = states
        self.requestOutcomes = requestOutcomes
    }

    public func state(for kind: PermissionKind) async -> PermissionState {
        guard supportedKinds.isEmpty || supportedKinds.contains(kind) else { return .unavailable }
        return states[kind] ?? defaultState
    }

    public func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome {
        guard supportedKinds.isEmpty || supportedKinds.contains(kind) else {
            throw PermissionError.unsupportedKind(kind)
        }

        if let outcome = requestOutcomes[kind] {
            states[kind] = outcome.state
            return outcome
        }

        let current = states[kind] ?? defaultState
        let next: PermissionState = current == .notDetermined ? .authorized : current
        states[kind] = next
        return PermissionRequestOutcome(kind: kind, state: next, didPromptUser: current == .notDetermined)
    }

    public func setState(_ state: PermissionState, for kind: PermissionKind) {
        states[kind] = state
    }

    public func setRequestOutcome(_ outcome: PermissionRequestOutcome, for kind: PermissionKind) {
        requestOutcomes[kind] = outcome
    }

    public func removeRequestOutcome(for kind: PermissionKind) {
        requestOutcomes.removeValue(forKey: kind)
    }
}
