import Foundation

public enum BuiltInValidationRule: Sendable, ValidationRule, CustomStringConvertible, CustomDebugStringConvertible {
    case required(ruleID: ValidationRuleID, code: ValidationCode, severity: ValidationSeverity)
    case textLengthAtLeast(ruleID: ValidationRuleID, minimum: Int, code: ValidationCode, severity: ValidationSeverity)
    case textLengthAtMost(ruleID: ValidationRuleID, maximum: Int, code: ValidationCode, severity: ValidationSeverity)
    case integerAtLeast(ruleID: ValidationRuleID, minimum: Int, code: ValidationCode, severity: ValidationSeverity)
    case integerAtMost(ruleID: ValidationRuleID, maximum: Int, code: ValidationCode, severity: ValidationSeverity)
    case decimalBetween(ruleID: ValidationRuleID, lowerBound: Double, upperBound: Double, code: ValidationCode, severity: ValidationSeverity)
    case matchesValue(ruleID: ValidationRuleID, otherValueID: ValidationValueID, code: ValidationCode, severity: ValidationSeverity)

    public var id: ValidationRuleID {
        switch self {
        case .required(let ruleID, _, _),
             .textLengthAtLeast(let ruleID, _, _, _),
             .textLengthAtMost(let ruleID, _, _, _),
             .integerAtLeast(let ruleID, _, _, _),
             .integerAtMost(let ruleID, _, _, _),
             .decimalBetween(let ruleID, _, _, _, _),
             .matchesValue(let ruleID, _, _, _):
            return ruleID
        }
    }

    public func evaluate(_ input: ValidationRuleInput) async -> ValidationResult {
        switch self {
        case .required(_, let code, let severity):
            return input.value.isEmptyLike ? issue(code: code, severity: severity) : .valid
        case .textLengthAtLeast(_, let minimum, let code, let severity):
            guard case .text(let text) = input.value else {
                return issue(code: code, severity: severity)
            }
            return text.count >= minimum ? .valid : issue(code: code, severity: severity)
        case .textLengthAtMost(_, let maximum, let code, let severity):
            guard case .text(let text) = input.value else {
                return issue(code: code, severity: severity)
            }
            return text.count <= maximum ? .valid : issue(code: code, severity: severity)
        case .integerAtLeast(_, let minimum, let code, let severity):
            guard case .integer(let number) = input.value else {
                return issue(code: code, severity: severity)
            }
            return number >= minimum ? .valid : issue(code: code, severity: severity)
        case .integerAtMost(_, let maximum, let code, let severity):
            guard case .integer(let number) = input.value else {
                return issue(code: code, severity: severity)
            }
            return number <= maximum ? .valid : issue(code: code, severity: severity)
        case .decimalBetween(_, let lowerBound, let upperBound, let code, let severity):
            guard case .decimal(let number) = input.value else {
                return issue(code: code, severity: severity)
            }
            return (lowerBound...upperBound).contains(number) ? .valid : issue(code: code, severity: severity)
        case .matchesValue(_, let otherValueID, let code, let severity):
            guard let otherValue = input.context.value(for: otherValueID) else {
                return issue(code: code, severity: severity)
            }
            return input.value == otherValue ? .valid : issue(code: code, severity: severity)
        }
    }

    public static func required(ruleID: String = "required", code: String = "required") throws -> BuiltInValidationRule {
        .required(
            ruleID: try ValidationRuleID(ruleID),
            code: try ValidationCode(code),
            severity: .error
        )
    }

    public static func textLengthAtLeast(_ minimum: Int, ruleID: String, code: String) throws -> BuiltInValidationRule {
        guard minimum >= 0 else {
            throw ValidationFailure.invalidLimit(reason: .negative)
        }
        return .textLengthAtLeast(
            ruleID: try ValidationRuleID(ruleID),
            minimum: minimum,
            code: try ValidationCode(code),
            severity: .error
        )
    }

    public static func textLengthAtMost(_ maximum: Int, ruleID: String, code: String) throws -> BuiltInValidationRule {
        guard maximum > 0 else {
            throw ValidationFailure.invalidLimit(reason: .zeroMaximum)
        }
        return .textLengthAtMost(
            ruleID: try ValidationRuleID(ruleID),
            maximum: maximum,
            code: try ValidationCode(code),
            severity: .error
        )
    }

    public static func decimalBetween(_ lowerBound: Double, _ upperBound: Double, ruleID: String, code: String) throws -> BuiltInValidationRule {
        guard lowerBound <= upperBound else {
            throw ValidationFailure.invalidLimit(reason: .invertedRange)
        }
        return .decimalBetween(
            ruleID: try ValidationRuleID(ruleID),
            lowerBound: lowerBound,
            upperBound: upperBound,
            code: try ValidationCode(code),
            severity: .error
        )
    }

    public var description: String {
        "BuiltInValidationRule(id: redacted)"
    }

    public var debugDescription: String {
        description
    }

    private func issue(code: ValidationCode, severity: ValidationSeverity) -> ValidationResult {
        ValidationResult(issues: [ValidationIssue(code: code, severity: severity, ruleID: id)])
    }
}
