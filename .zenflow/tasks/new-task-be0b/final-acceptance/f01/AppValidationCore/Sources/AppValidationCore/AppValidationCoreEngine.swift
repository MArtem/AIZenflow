import Foundation

public actor AppValidationCoreEngine {
    public init() {}

    public func validate(_ input: ValidationRuleInput, using ruleSet: ValidationRuleSet) async -> ValidationResult {
        var result = ValidationResult.valid
        for rule in ruleSet.rules {
            let ruleResult = await rule.evaluate(input)
            result = result.merging(ruleResult)
        }
        return result
    }

    public func validate(values: [NamedValidationValue], using ruleSetsByValue: [ValidationValueID: ValidationRuleSet]) async throws -> [ValidationValueID: ValidationResult] {
        let context = try ValidationContext(values: values)
        var output: [ValidationValueID: ValidationResult] = [:]

        for value in values where ruleSetsByValue[value.id] == nil {
            output[value.id] = .valid
        }

        for (valueID, ruleSet) in ruleSetsByValue {
            let value = context.value(for: valueID) ?? .missing
            let input = ValidationRuleInput(valueID: valueID, value: value, context: context)
            output[valueID] = await validate(input, using: ruleSet)
        }

        return output
    }
}
