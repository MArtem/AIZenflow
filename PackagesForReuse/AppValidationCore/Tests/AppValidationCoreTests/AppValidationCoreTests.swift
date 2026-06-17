import XCTest
@testable import AppValidationCore

final class AppValidationCoreTests: XCTestCase {
    func testSafeIdentifierRejectsUnsupportedCharactersAndRedactsDescription() throws {
        XCTAssertThrowsError(try ValidationValueID("../field"))

        let id = try ValidationValueID("profile.email")
        XCTAssertEqual(id.value, "profile.email")
        XCTAssertFalse(id.description.contains("profile.email"))
    }

    func testRequiredRuleFlagsMissingAndBlankText() async throws {
        let fieldID = try ValidationValueID("name")
        let rule = try BuiltInValidationRule.required(ruleID: "name.required", code: "required")

        let missingResult = await rule.evaluate(ValidationRuleInput(valueID: fieldID, value: .missing))
        let blankResult = await rule.evaluate(ValidationRuleInput(valueID: fieldID, value: .text("   ")))
        let filledResult = await rule.evaluate(ValidationRuleInput(valueID: fieldID, value: .text("Alex")))

        XCTAssertFalse(missingResult.isValid)
        XCTAssertFalse(blankResult.isValid)
        XCTAssertTrue(filledResult.isValid)
    }

    func testTextLengthRulesValidateBounds() async throws {
        let fieldID = try ValidationValueID("title")
        let minRule = try BuiltInValidationRule.textLengthAtLeast(3, ruleID: "title.min", code: "too_short")
        let maxRule = try BuiltInValidationRule.textLengthAtMost(5, ruleID: "title.max", code: "too_long")

        let shortResult = await minRule.evaluate(ValidationRuleInput(valueID: fieldID, value: .text("Hi")))
        let longResult = await maxRule.evaluate(ValidationRuleInput(valueID: fieldID, value: .text("Welcome")))
        let validResult = await maxRule.evaluate(ValidationRuleInput(valueID: fieldID, value: .text("Hello")))

        XCTAssertFalse(shortResult.isValid)
        XCTAssertFalse(longResult.isValid)
        XCTAssertTrue(validResult.isValid)
    }

    func testDecimalBetweenRejectsInvertedRangeAndValidatesValue() async throws {
        XCTAssertThrowsError(try BuiltInValidationRule.decimalBetween(10, 1, ruleID: "range", code: "range"))

        let fieldID = try ValidationValueID("amount")
        let rule = try BuiltInValidationRule.decimalBetween(1, 10, ruleID: "amount.range", code: "out_of_range")

        let validResult = await rule.evaluate(ValidationRuleInput(valueID: fieldID, value: .decimal(5)))
        let invalidResult = await rule.evaluate(ValidationRuleInput(valueID: fieldID, value: .decimal(12)))

        XCTAssertTrue(validResult.isValid)
        XCTAssertFalse(invalidResult.isValid)
    }

    func testRuleSetRejectsDuplicateRuleIDs() throws {
        let first = try BuiltInValidationRule.required(ruleID: "required", code: "required")
        let second = try BuiltInValidationRule.required(ruleID: "required", code: "required_again")

        XCTAssertThrowsError(
            try ValidationRuleSet(
                id: try ValidationSetID("set"),
                rules: [first, second]
            )
        )
    }

    func testEngineAggregatesIssues() async throws {
        let fieldID = try ValidationValueID("username")
        let rules = try ValidationRuleSet(
            id: try ValidationSetID("username.rules"),
            rules: [
                try BuiltInValidationRule.required(ruleID: "username.required", code: "required"),
                try BuiltInValidationRule.textLengthAtLeast(3, ruleID: "username.min", code: "too_short")
            ]
        )
        let engine = AppValidationCoreEngine()

        let result = await engine.validate(
            ValidationRuleInput(valueID: fieldID, value: .text("")),
            using: rules
        )

        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.issues.count, 2)
        XCTAssertFalse(result.description.contains("username"))
    }

    func testCrossValueRuleUsesContextWithoutExposingValues() async throws {
        let primaryID = try ValidationValueID("primary")
        let confirmID = try ValidationValueID("confirm")
        let rule = BuiltInValidationRule.matchesValue(
            ruleID: try ValidationRuleID("confirm.match"),
            otherValueID: primaryID,
            code: try ValidationCode("mismatch"),
            severity: .error
        )
        let context = try ValidationContext(values: [
            NamedValidationValue(id: primaryID, value: .text("alpha")),
            NamedValidationValue(id: confirmID, value: .text("beta"))
        ])

        let result = await rule.evaluate(
            ValidationRuleInput(valueID: confirmID, value: .text("beta"), context: context)
        )

        XCTAssertFalse(result.isValid)
        XCTAssertFalse(context.description.contains("alpha"))
        XCTAssertFalse(context.description.contains("beta"))
    }

    func testBulkValidationRunsConfiguredRulesForMissingValues() async throws {
        let fieldID = try ValidationValueID("email")
        let rules = try ValidationRuleSet(
            id: try ValidationSetID("email.rules"),
            rules: [
                try BuiltInValidationRule.required(ruleID: "email.required", code: "required")
            ]
        )
        let engine = AppValidationCoreEngine()

        let results = try await engine.validate(values: [], using: [fieldID: rules])

        XCTAssertFalse(results[fieldID]?.isValid ?? true)
        XCTAssertEqual(results[fieldID]?.issues.first?.code, try ValidationCode("required"))
    }

    func testValidationContextRejectsDuplicateValueIDs() throws {
        let fieldID = try ValidationValueID("email")

        XCTAssertThrowsError(
            try ValidationContext(values: [
                NamedValidationValue(id: fieldID, value: .text("first")),
                NamedValidationValue(id: fieldID, value: .text("second"))
            ])
        ) { error in
            XCTAssertEqual(error as? ValidationFailure, .invalidContext(reason: .duplicateValue))
        }
    }

    func testSafeIdentifierStringDescriptionsAreRedacted() throws {
        let identifier = try SafeValidationIdentifier("private.email")

        XCTAssertFalse(String(describing: identifier).contains("private.email"))
        XCTAssertFalse(String(reflecting: identifier).contains("private.email"))
    }

    func testCodableRoundTripKeepsValidationResult() throws {
        let issue = ValidationIssue(
            code: try ValidationCode("required"),
            severity: .error,
            ruleID: try ValidationRuleID("required.rule")
        )
        let result = ValidationResult(issues: [issue])
        let data = try JSONEncoder().encode(result)
        let decoded = try JSONDecoder().decode(ValidationResult.self, from: data)

        XCTAssertEqual(decoded, result)
        XCTAssertFalse(decoded.isValid)
    }
}
