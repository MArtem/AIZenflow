import Foundation

public struct FormFieldValidationPlan: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let fieldID: FormFieldID
    public let rules: [BuiltInFormValidationRule]

    public init(fieldID: FormFieldID, rules: [BuiltInFormValidationRule]) throws {
        var seen: Set<FormValidationRuleID> = []
        for rule in rules {
            guard seen.insert(rule.id).inserted else {
                throw FormValidationFailure.duplicateRule
            }
        }
        self.fieldID = fieldID
        self.rules = rules
    }

    public var description: String {
        "FormFieldValidationPlan(fieldID:\(fieldID),ruleCount:\(rules.count))"
    }

    public var debugDescription: String { description }
}

public struct FormValidationPlan: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let formID: FormID
    public let fieldPlans: [FormFieldValidationPlan]

    public init(formID: FormID, fieldPlans: [FormFieldValidationPlan]) throws {
        var seen: Set<FormFieldID> = []
        for plan in fieldPlans {
            guard seen.insert(plan.fieldID).inserted else {
                throw FormValidationFailure.duplicateField
            }
        }
        self.formID = formID
        self.fieldPlans = fieldPlans
    }

    public var description: String {
        "FormValidationPlan(formID:\(formID),fieldPlanCount:\(fieldPlans.count))"
    }

    public var debugDescription: String { description }
}
