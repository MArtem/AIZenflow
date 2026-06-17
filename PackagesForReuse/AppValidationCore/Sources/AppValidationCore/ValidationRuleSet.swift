import Foundation

public struct ValidationRuleSet: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let id: ValidationSetID
    public let rules: [any ValidationRule]

    public init(id: ValidationSetID, rules: [any ValidationRule]) throws {
        guard !rules.isEmpty else {
            throw ValidationFailure.invalidRuleSet(reason: .empty)
        }
        var seen = Set<ValidationRuleID>()
        for rule in rules {
            guard seen.insert(rule.id).inserted else {
                throw ValidationFailure.invalidRuleSet(reason: .duplicateRule)
            }
        }
        self.id = id
        self.rules = rules
    }

    public var description: String {
        "ValidationRuleSet(id: redacted, ruleCount: \(rules.count))"
    }

    public var debugDescription: String {
        description
    }
}
