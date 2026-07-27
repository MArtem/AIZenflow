import Foundation

public enum FormValidationSeverity: String, Codable, Equatable, Sendable {
    case warning
    case error
}

public struct FormValidationIssue: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let fieldID: FormFieldID?
    public let ruleID: FormValidationRuleID
    public let code: FormValidationCode
    public let severity: FormValidationSeverity

    public init(fieldID: FormFieldID?, ruleID: FormValidationRuleID, code: FormValidationCode, severity: FormValidationSeverity = .error) {
        self.fieldID = fieldID
        self.ruleID = ruleID
        self.code = code
        self.severity = severity
    }

    public var description: String {
        "FormValidationIssue(field:\(fieldID.map { $0.description } ?? "none"),rule:\(ruleID),code:\(code),severity:\(severity.rawValue))"
    }

    public var debugDescription: String { description }
}

public struct FormValidationRuleResult: Codable, Equatable, Sendable {
    public let issues: [FormValidationIssue]

    public init(issues: [FormValidationIssue]) {
        self.issues = issues
    }

    public static var valid: FormValidationRuleResult {
        FormValidationRuleResult(issues: [])
    }

    public var isValid: Bool { issues.isEmpty }
}
