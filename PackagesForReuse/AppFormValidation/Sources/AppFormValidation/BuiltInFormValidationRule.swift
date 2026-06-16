import Foundation

public enum BuiltInFormValidationRule: Codable, Equatable, Sendable, FormValidationRule, CustomStringConvertible, CustomDebugStringConvertible {
    case required(id: FormValidationRuleID, code: FormValidationCode, severity: FormValidationSeverity)
    case minLength(id: FormValidationRuleID, length: Int, code: FormValidationCode, severity: FormValidationSeverity)
    case maxLength(id: FormValidationRuleID, length: Int, code: FormValidationCode, severity: FormValidationSeverity)
    case equalsField(id: FormValidationRuleID, otherFieldID: FormFieldID, code: FormValidationCode, severity: FormValidationSeverity)

    public var id: FormValidationRuleID {
        switch self {
        case .required(let id, _, _),
             .minLength(let id, _, _, _),
             .maxLength(let id, _, _, _),
             .equalsField(let id, _, _, _):
            return id
        }
    }

    public func validate(fieldID: FormFieldID, value: FormFieldValue, context: FormValidationContext) async throws -> FormValidationRuleResult {
        switch self {
        case .required(_, let code, let severity):
            guard value.isEmptyForValidation else {
                return .valid
            }
            return FormValidationRuleResult(issues: [issue(fieldID: fieldID, code: code, severity: severity)])
        case .minLength(_, let length, let code, let severity):
            try validateLimit(length, label: "minLength")
            guard let count = value.stringCountForValidation, count < length, !value.isEmptyForValidation else {
                return .valid
            }
            return FormValidationRuleResult(issues: [issue(fieldID: fieldID, code: code, severity: severity)])
        case .maxLength(_, let length, let code, let severity):
            try validateLimit(length, label: "maxLength")
            guard let count = value.stringCountForValidation, count > length else {
                return .valid
            }
            return FormValidationRuleResult(issues: [issue(fieldID: fieldID, code: code, severity: severity)])
        case .equalsField(_, let otherFieldID, let code, let severity):
            guard let other = context.snapshot.field(otherFieldID) else {
                throw FormValidationFailure.missingField
            }
            guard value != other.value else {
                return .valid
            }
            return FormValidationRuleResult(issues: [issue(fieldID: fieldID, code: code, severity: severity)])
        }
    }

    public var description: String {
        switch self {
        case .required:
            return "BuiltInFormValidationRule.required(id:\(id))"
        case .minLength(_, let length, _, _):
            return "BuiltInFormValidationRule.minLength(id:\(id),length:\(length))"
        case .maxLength(_, let length, _, _):
            return "BuiltInFormValidationRule.maxLength(id:\(id),length:\(length))"
        case .equalsField:
            return "BuiltInFormValidationRule.equalsField(id:\(id),otherField:<redacted>)"
        }
    }

    public var debugDescription: String { description }

    private func issue(fieldID: FormFieldID, code: FormValidationCode, severity: FormValidationSeverity) -> FormValidationIssue {
        FormValidationIssue(fieldID: fieldID, ruleID: id, code: code, severity: severity)
    }

    private func validateLimit(_ limit: Int, label: String) throws {
        guard limit >= 0 else {
            throw FormValidationFailure.invalidLimit(label: label)
        }
    }
}
