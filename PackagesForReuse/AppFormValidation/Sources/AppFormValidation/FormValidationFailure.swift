import Foundation

public enum FormValidationFailure: Error, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public enum InvalidIdentifierReason: Equatable, Sendable {
        case empty
        case tooLong(maximum: Int)
        case containsUnsafeCharacters
    }

    case invalidIdentifier(label: String, reason: InvalidIdentifierReason)
    case invalidLimit(label: String)
    case duplicateRule
    case duplicateField
    case formMismatch
    case missingField
    case missingSnapshot
    case invalidRevision
    case revisionOverflow

    public var description: String {
        switch self {
        case .invalidIdentifier(let label, let reason):
            return "FormValidationFailure.invalidIdentifier(label:\(label),reason:\(reason.safeDescription))"
        case .invalidLimit(let label):
            return "FormValidationFailure.invalidLimit(label:\(label))"
        case .duplicateRule:
            return "FormValidationFailure.duplicateRule"
        case .duplicateField:
            return "FormValidationFailure.duplicateField"
        case .formMismatch:
            return "FormValidationFailure.formMismatch"
        case .missingField:
            return "FormValidationFailure.missingField"
        case .missingSnapshot:
            return "FormValidationFailure.missingSnapshot"
        case .invalidRevision:
            return "FormValidationFailure.invalidRevision"
        case .revisionOverflow:
            return "FormValidationFailure.revisionOverflow"
        }
    }

    public var debugDescription: String { description }
}

extension FormValidationFailure.InvalidIdentifierReason {
    var safeDescription: String {
        switch self {
        case .empty:
            return "empty"
        case .tooLong(let maximum):
            return "tooLong(maximum:\(maximum))"
        case .containsUnsafeCharacters:
            return "containsUnsafeCharacters"
        }
    }
}
