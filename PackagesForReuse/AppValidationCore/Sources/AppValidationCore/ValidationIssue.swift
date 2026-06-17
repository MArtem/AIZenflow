import Foundation

public enum ValidationSeverity: String, Codable, Sendable, Comparable {
    case info
    case warning
    case error

    public static func < (lhs: ValidationSeverity, rhs: ValidationSeverity) -> Bool {
        lhs.rank < rhs.rank
    }

    private var rank: Int {
        switch self {
        case .info:
            return 0
        case .warning:
            return 1
        case .error:
            return 2
        }
    }
}

public struct ValidationIssue: Equatable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let code: ValidationCode
    public let severity: ValidationSeverity
    public let ruleID: ValidationRuleID

    public init(code: ValidationCode, severity: ValidationSeverity, ruleID: ValidationRuleID) {
        self.code = code
        self.severity = severity
        self.ruleID = ruleID
    }

    public var description: String {
        "ValidationIssue(severity: \(severity), code: redacted, rule: redacted)"
    }

    public var debugDescription: String {
        description
    }
}
