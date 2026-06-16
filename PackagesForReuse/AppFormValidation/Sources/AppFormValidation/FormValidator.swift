import Foundation

public actor FormValidator {
    private let plan: FormValidationPlan
    private let externalRules: [any FormValidationRule]

    public init(plan: FormValidationPlan, externalRules: [any FormValidationRule] = []) {
        self.plan = plan
        self.externalRules = externalRules
    }

    public func validate(_ snapshot: FormSnapshot) async throws -> FormValidationResult {
        guard snapshot.formID == plan.formID else {
            throw FormValidationFailure.formMismatch
        }
        let context = FormValidationContext(formID: plan.formID, snapshot: snapshot)
        var issues: [FormValidationIssue] = []

        for fieldPlan in plan.fieldPlans {
            guard let field = snapshot.field(fieldPlan.fieldID) else {
                throw FormValidationFailure.missingField
            }
            for rule in fieldPlan.rules {
                let result = try await rule.validate(fieldID: field.id, value: field.value, context: context)
                issues.append(contentsOf: result.issues)
            }
            for rule in externalRules {
                let result = try await rule.validate(fieldID: field.id, value: field.value, context: context)
                issues.append(contentsOf: result.issues)
            }
        }

        return FormValidationResult(formID: snapshot.formID, revision: snapshot.revision, issues: issues)
    }
}
