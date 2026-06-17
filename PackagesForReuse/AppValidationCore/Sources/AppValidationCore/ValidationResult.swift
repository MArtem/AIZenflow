import Foundation

public struct ValidationResult: Equatable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let issues: [ValidationIssue]

    public init(issues: [ValidationIssue]) {
        self.issues = issues
    }

    public static var valid: ValidationResult {
        ValidationResult(issues: [])
    }

    public var isValid: Bool {
        !issues.contains { $0.severity == .error }
    }

    public var mostSevereIssue: ValidationIssue? {
        issues.max { $0.severity < $1.severity }
    }

    public func merging(_ other: ValidationResult) -> ValidationResult {
        ValidationResult(issues: issues + other.issues)
    }

    public var description: String {
        "ValidationResult(isValid: \(isValid), issueCount: \(issues.count))"
    }

    public var debugDescription: String {
        description
    }
}
