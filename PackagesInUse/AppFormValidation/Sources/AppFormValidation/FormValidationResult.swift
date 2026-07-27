import Foundation

public struct FormValidationResult: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let formID: FormID
    public let revision: Int
    public let issues: [FormValidationIssue]

    public init(formID: FormID, revision: Int, issues: [FormValidationIssue]) {
        self.formID = formID
        self.revision = revision
        self.issues = issues
    }

    public var isValid: Bool { issues.allSatisfy { $0.severity != .error } }

    public func issues(for fieldID: FormFieldID) -> [FormValidationIssue] {
        issues.filter { $0.fieldID == fieldID }
    }

    public var description: String {
        "FormValidationResult(formID:\(formID),revision:\(revision),issueCount:\(issues.count),isValid:\(isValid))"
    }

    public var debugDescription: String { description }
}
