import Foundation

public struct ValidationRuleInput: Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let valueID: ValidationValueID
    public let value: ValidationValue
    public let context: ValidationContext

    public init(valueID: ValidationValueID, value: ValidationValue, context: ValidationContext = ValidationContext()) {
        self.valueID = valueID
        self.value = value
        self.context = context
    }

    public var description: String {
        "ValidationRuleInput(valueID: redacted, kind: \(value.kind))"
    }

    public var debugDescription: String {
        description
    }
}

public protocol ValidationRule: Sendable {
    var id: ValidationRuleID { get }
    func evaluate(_ input: ValidationRuleInput) async -> ValidationResult
}
