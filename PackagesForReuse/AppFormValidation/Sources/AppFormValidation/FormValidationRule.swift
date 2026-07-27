import Foundation

public protocol FormValidationRule: Sendable {
    var id: FormValidationRuleID { get }
    func validate(fieldID: FormFieldID, value: FormFieldValue, context: FormValidationContext) async throws -> FormValidationRuleResult
}
