import Foundation

public struct StateTransitionEvaluation: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let definition: StateMachineDefinition
    public let currentSnapshot: StateMachineSnapshot
    public let event: StateMachineEvent
    public let transition: StateTransition

    public init(
        definition: StateMachineDefinition,
        currentSnapshot: StateMachineSnapshot,
        event: StateMachineEvent,
        transition: StateTransition
    ) {
        self.definition = definition
        self.currentSnapshot = currentSnapshot
        self.event = event
        self.transition = transition
    }

    public var description: String {
        "<redacted:StateTransitionEvaluation,revision:\(currentSnapshot.revision)>"
    }

    public var debugDescription: String { description }
}

public protocol StateTransitionGuard: Sendable {
    var id: StateGuardID { get }
    func allowsTransition(_ evaluation: StateTransitionEvaluation) async -> Bool
}

public protocol StateTransitionAction: Sendable {
    var id: StateActionID { get }
    func executeTransition(_ evaluation: StateTransitionEvaluation) async throws
}
