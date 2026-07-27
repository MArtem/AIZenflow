import Foundation

public enum StateMachineFailure: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidIdentifier(label: String, reason: IdentifierReason)
    case duplicateState
    case duplicateTransition
    case missingInitialState
    case transitionReferencesUnknownState
    case transitionNotDefined
    case guardNotRegistered
    case actionNotRegistered
    case actionFailed
    case metadataLimitExceeded(maximumBytes: Int)

    public enum IdentifierReason: Equatable, Sendable {
        case empty
        case tooLong(maximum: Int)
        case containsUnsafeCharacters
    }

    public var description: String {
        switch self {
        case .invalidIdentifier(let label, let reason):
            "StateMachineFailure.invalidIdentifier(label:\(label),reason:\(reason.redactedDescription))"
        case .duplicateState:
            "StateMachineFailure.duplicateState"
        case .duplicateTransition:
            "StateMachineFailure.duplicateTransition"
        case .missingInitialState:
            "StateMachineFailure.missingInitialState"
        case .transitionReferencesUnknownState:
            "StateMachineFailure.transitionReferencesUnknownState"
        case .transitionNotDefined:
            "StateMachineFailure.transitionNotDefined"
        case .guardNotRegistered:
            "StateMachineFailure.guardNotRegistered"
        case .actionNotRegistered:
            "StateMachineFailure.actionNotRegistered"
        case .actionFailed:
            "StateMachineFailure.actionFailed"
        case .metadataLimitExceeded(let maximumBytes):
            "StateMachineFailure.metadataLimitExceeded(maximumBytes:\(maximumBytes))"
        }
    }
}

extension StateMachineFailure.IdentifierReason {
    var redactedDescription: String {
        switch self {
        case .empty:
            "empty"
        case .tooLong(let maximum):
            "tooLong(maximum:\(maximum))"
        case .containsUnsafeCharacters:
            "containsUnsafeCharacters"
        }
    }
}
