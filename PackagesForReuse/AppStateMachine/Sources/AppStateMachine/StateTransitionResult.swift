import Foundation

public enum StateTransitionRejection: Equatable, Sendable, CustomStringConvertible {
    case transitionNotDefined
    case guardNotRegistered
    case guardRejected
    case actionNotRegistered
    case actionFailed

    public var description: String {
        switch self {
        case .transitionNotDefined:
            "StateTransitionRejection.transitionNotDefined"
        case .guardNotRegistered:
            "StateTransitionRejection.guardNotRegistered"
        case .guardRejected:
            "StateTransitionRejection.guardRejected"
        case .actionNotRegistered:
            "StateTransitionRejection.actionNotRegistered"
        case .actionFailed:
            "StateTransitionRejection.actionFailed"
        }
    }
}

public enum StateTransitionResult: Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    case accepted(StateMachineSnapshot)
    case rejected(StateTransitionRejection, StateMachineSnapshot)

    public var isAccepted: Bool {
        switch self {
        case .accepted:
            true
        case .rejected:
            false
        }
    }

    public var snapshot: StateMachineSnapshot {
        switch self {
        case .accepted(let snapshot):
            snapshot
        case .rejected(_, let snapshot):
            snapshot
        }
    }

    public var description: String {
        switch self {
        case .accepted(let snapshot):
            "<redacted:StateTransitionResult.accepted,revision:\(snapshot.revision)>"
        case .rejected(let reason, let snapshot):
            "<redacted:StateTransitionResult.rejected,reason:\(reason),revision:\(snapshot.revision)>"
        }
    }

    public var debugDescription: String { description }
}
