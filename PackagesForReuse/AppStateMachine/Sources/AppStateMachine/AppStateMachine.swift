import Foundation

public actor AppStateMachine {
    private let definition: StateMachineDefinition
    private let store: any StateMachineStore
    private let clock: any StateMachineClock
    private let transitionLock: StateMachineTransitionLock
    private var guards: [StateGuardID: any StateTransitionGuard]
    private var actions: [StateActionID: any StateTransitionAction]

    public init(
        definition: StateMachineDefinition,
        store: any StateMachineStore = InMemoryStateMachineStore(),
        clock: any StateMachineClock = SystemStateMachineClock(),
        guards: [any StateTransitionGuard] = [],
        actions: [any StateTransitionAction] = []
    ) {
        self.definition = definition
        self.store = store
        self.clock = clock
        self.transitionLock = StateMachineTransitionLock()
        var guardRegistry: [StateGuardID: any StateTransitionGuard] = [:]
        for guardRule in guards {
            guardRegistry[guardRule.id] = guardRule
        }
        var actionRegistry: [StateActionID: any StateTransitionAction] = [:]
        for action in actions {
            actionRegistry[action.id] = action
        }
        self.guards = guardRegistry
        self.actions = actionRegistry
    }

    public func registerGuard(_ guardRule: any StateTransitionGuard) {
        guards[guardRule.id] = guardRule
    }

    public func registerAction(_ action: any StateTransitionAction) {
        actions[action.id] = action
    }

    public func currentSnapshot() async throws -> StateMachineSnapshot {
        if let snapshot = try await store.loadSnapshot(for: definition.id) {
            return snapshot
        }
        let instant = await clock.now()
        return StateMachineSnapshot(
            machineID: definition.id,
            state: definition.initialState,
            updatedAt: instant
        )
    }

    public func resetToInitialState() async throws -> StateMachineSnapshot {
        try await transitionLock.withLock {
            try await self.performResetToInitialState()
        }
    }

    public func send(_ event: StateMachineEvent) async throws -> StateTransitionResult {
        try await transitionLock.withLock {
            try await self.performSend(event)
        }
    }

    private func performResetToInitialState() async throws -> StateMachineSnapshot {
        try await store.resetSnapshot(for: definition.id)
        let instant = await clock.now()
        let snapshot = StateMachineSnapshot(
            machineID: definition.id,
            state: definition.initialState,
            updatedAt: instant
        )
        try await store.saveSnapshot(snapshot)
        return snapshot
    }

    private func performSend(_ event: StateMachineEvent) async throws -> StateTransitionResult {
        let current = try await currentSnapshot()
        guard let transition = definition.transition(from: current.state, event: event.id) else {
            return .rejected(.transitionNotDefined, current)
        }

        let evaluation = StateTransitionEvaluation(
            definition: definition,
            currentSnapshot: current,
            event: event,
            transition: transition
        )

        if let guardID = transition.guardID {
            guard let guardRule = guards[guardID] else {
                return .rejected(.guardNotRegistered, current)
            }
            let allowed = await guardRule.allowsTransition(evaluation)
            guard allowed else {
                return .rejected(.guardRejected, current)
            }
        }

        if let actionID = transition.actionID {
            guard let action = actions[actionID] else {
                return .rejected(.actionNotRegistered, current)
            }
            do {
                try await action.executeTransition(evaluation)
            } catch {
                return .rejected(.actionFailed, current)
            }
        }

        let instant = await clock.now()
        let next = current.applying(transition: transition, event: event, at: instant)
        try await store.saveSnapshot(next)
        return .accepted(next)
    }
}

private actor StateMachineTransitionLock {
    private var isLocked = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func withLock<T: Sendable>(
        _ operation: @Sendable () async throws -> T
    ) async throws -> T {
        await acquire()
        defer { release() }
        return try await operation()
    }

    private func acquire() async {
        if !isLocked {
            isLocked = true
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    private nonisolated func release() {
        Task {
            await releaseOnActor()
        }
    }

    private func releaseOnActor() {
        if waiters.isEmpty {
            isLocked = false
        } else {
            let next = waiters.removeFirst()
            next.resume()
        }
    }
}
