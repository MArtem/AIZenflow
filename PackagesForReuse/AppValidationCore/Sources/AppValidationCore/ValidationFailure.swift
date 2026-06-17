import Foundation

public enum ValidationFailure: Error, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    case invalidIdentifier(reason: IdentifierReason)
    case invalidLimit(reason: LimitReason)
    case invalidRuleSet(reason: RuleSetReason)
    case invalidContext(reason: ContextReason)
    case unsupportedValue(expected: ValidationValueKind)

    public enum IdentifierReason: Equatable, Sendable {
        case empty
        case tooLong(maximum: Int)
        case unsupportedCharacter
    }

    public enum LimitReason: Equatable, Sendable {
        case negative
        case invertedRange
        case zeroMaximum
    }

    public enum RuleSetReason: Equatable, Sendable {
        case empty
        case duplicateRule
    }

    public enum ContextReason: Equatable, Sendable {
        case duplicateValue
    }

    public var description: String {
        switch self {
        case .invalidIdentifier:
            return "ValidationFailure.invalidIdentifier(redacted)"
        case .invalidLimit:
            return "ValidationFailure.invalidLimit"
        case .invalidRuleSet:
            return "ValidationFailure.invalidRuleSet"
        case .invalidContext:
            return "ValidationFailure.invalidContext"
        case .unsupportedValue(let expected):
            return "ValidationFailure.unsupportedValue(expected: \(expected))"
        }
    }

    public var debugDescription: String {
        description
    }
}
