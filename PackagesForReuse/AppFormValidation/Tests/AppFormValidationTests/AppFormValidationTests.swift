import XCTest
@testable import AppFormValidation

final class AppFormValidationTests: XCTestCase {
    func testIdentifierRejectsUnsafeCharacters() throws {
        XCTAssertThrowsError(try FormFieldID("../email"))
        XCTAssertThrowsError(try FormValidationCode(""))
    }

    func testDescriptionsRedactValuesAndIdentifiers() throws {
        let fieldID = try FormFieldID("email")
        let state = FormFieldState(id: fieldID, value: .string("person@example.com"))

        XCTAssertFalse(state.description.contains("email"))
        XCTAssertFalse(state.description.contains("person@example.com"))
        XCTAssertTrue(state.description.contains("redacted"))
    }

    func testRequiredRuleProducesErrorForEmptyValue() async throws {
        let formID = try FormID("signup")
        let fieldID = try FormFieldID("email")
        let ruleID = try FormValidationRuleID("required")
        let code = try FormValidationCode("required")
        let snapshot = try FormSnapshot(formID: formID, fields: [FormFieldState(id: fieldID, value: .empty)])
        let plan = try FormValidationPlan(
            formID: formID,
            fieldPlans: [
                try FormFieldValidationPlan(fieldID: fieldID, rules: [.required(id: ruleID, code: code, severity: .error)])
            ]
        )

        let validator = FormValidator(plan: plan)
        let result = try await validator.validate(snapshot)

        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.issues.count, 1)
        XCTAssertEqual(result.issues.first?.fieldID, fieldID)
    }

    func testLengthRules() async throws {
        let formID = try FormID("profile")
        let fieldID = try FormFieldID("displayName")
        let minRuleID = try FormValidationRuleID("min")
        let maxRuleID = try FormValidationRuleID("max")
        let minCode = try FormValidationCode("tooShort")
        let maxCode = try FormValidationCode("tooLong")
        let snapshot = try FormSnapshot(formID: formID, fields: [FormFieldState(id: fieldID, value: .string("abc"))])
        let fieldPlan = try FormFieldValidationPlan(
            fieldID: fieldID,
            rules: [
                .minLength(id: minRuleID, length: 4, code: minCode, severity: .error),
                .maxLength(id: maxRuleID, length: 2, code: maxCode, severity: .warning)
            ]
        )
        let plan = try FormValidationPlan(formID: formID, fieldPlans: [fieldPlan])

        let validator = FormValidator(plan: plan)
        let result = try await validator.validate(snapshot)

        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.issues.count, 2)
        XCTAssertEqual(result.issues.filter { $0.severity == .error }.count, 1)
        XCTAssertEqual(result.issues.filter { $0.severity == .warning }.count, 1)
    }

    func testEqualsFieldRule() async throws {
        let formID = try FormID("change")
        let primaryID = try FormFieldID("primary")
        let confirmationID = try FormFieldID("confirmation")
        let ruleID = try FormValidationRuleID("matches")
        let code = try FormValidationCode("notEqual")
        let snapshot = try FormSnapshot(
            formID: formID,
            fields: [
                FormFieldState(id: primaryID, value: .string("abc")),
                FormFieldState(id: confirmationID, value: .string("xyz"))
            ]
        )
        let fieldPlan = try FormFieldValidationPlan(
            fieldID: confirmationID,
            rules: [.equalsField(id: ruleID, otherFieldID: primaryID, code: code, severity: .error)]
        )
        let plan = try FormValidationPlan(formID: formID, fieldPlans: [fieldPlan])

        let validator = FormValidator(plan: plan)
        let result = try await validator.validate(snapshot)

        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.issues.count, 1)
    }

    func testSnapshotUpdatesDirtyAndTouchedState() async throws {
        let formID = try FormID("settings")
        let fieldID = try FormFieldID("nickname")
        let initial = try FormSnapshot(formID: formID, fields: [FormFieldState(id: fieldID, value: .string("old"))])
        let updated = try initial.updatingField(fieldID, value: .string("new"))
        let field = updated.field(fieldID)

        XCTAssertEqual(updated.revision, 1)
        XCTAssertEqual(field?.isTouched, true)
        XCTAssertEqual(field?.isDirty, true)
    }

    func testInMemoryStoreAndController() async throws {
        let formID = try FormID("account")
        let fieldID = try FormFieldID("name")
        let snapshot = try FormSnapshot(formID: formID, fields: [FormFieldState(id: fieldID, value: .empty)])
        let ruleID = try FormValidationRuleID("required")
        let code = try FormValidationCode("required")
        let fieldPlan = try FormFieldValidationPlan(
            fieldID: fieldID,
            rules: [.required(id: ruleID, code: code, severity: .error)]
        )
        let plan = try FormValidationPlan(formID: formID, fieldPlans: [fieldPlan])
        let store = InMemoryFormSnapshotStore()
        let validator = FormValidator(plan: plan)
        let controller = try await FormStateController(formID: formID, initialSnapshot: snapshot, store: store, validator: validator)

        _ = try await controller.updateField(fieldID, value: .string("Artem"))
        let result = try await controller.validateCurrent()
        let current = try await controller.currentSnapshot()

        XCTAssertTrue(result.isValid)
        XCTAssertEqual(current.revision, 1)
    }
    func testSnapshotRevisionOverflowThrows() throws {
        let formID = try FormID("overflow")
        let fieldID = try FormFieldID("field")
        let snapshot = try FormSnapshot(
            formID: formID,
            revision: Int.max,
            fields: [FormFieldState(id: fieldID, value: .string("value"))]
        )

        XCTAssertThrowsError(try snapshot.markingTouched(fieldID)) { error in
            XCTAssertEqual(error as? FormValidationFailure, .revisionOverflow)
        }
    }

    func testControllerSerializesConcurrentUpdatesAcrossAwaitingStoreOperations() async throws {
        let formID = try FormID("concurrent")
        let firstID = try FormFieldID("first")
        let secondID = try FormFieldID("second")
        let snapshot = try FormSnapshot(
            formID: formID,
            fields: [
                FormFieldState(id: firstID, value: .string("old")),
                FormFieldState(id: secondID, value: .string("old"))
            ]
        )
        let store = DelayingFormSnapshotStore(loadDelayNanoseconds: 5_000_000)
        let plan = try FormValidationPlan(formID: formID, fieldPlans: [])
        let validator = FormValidator(plan: plan)
        let controller = try await FormStateController(formID: formID, initialSnapshot: snapshot, store: store, validator: validator)

        async let first: FormSnapshot = controller.updateField(firstID, value: .string("new"))
        async let second: FormSnapshot = controller.updateField(secondID, value: .string("new"))
        _ = try await [first, second]
        let current = try await controller.currentSnapshot()

        XCTAssertEqual(current.revision, 2)
        XCTAssertEqual(current.field(firstID)?.value, .string("new"))
        XCTAssertEqual(current.field(secondID)?.value, .string("new"))
    }

    func testControllerReportsMissingSnapshotSeparatelyFromMissingField() async throws {
        let formID = try FormID("missingSnapshot")
        let fieldID = try FormFieldID("name")
        let snapshot = try FormSnapshot(formID: formID, fields: [FormFieldState(id: fieldID, value: .empty)])
        let store = InMemoryFormSnapshotStore()
        let plan = try FormValidationPlan(formID: formID, fieldPlans: [])
        let validator = FormValidator(plan: plan)
        let controller = try await FormStateController(formID: formID, initialSnapshot: snapshot, store: store, validator: validator)
        try await store.remove(formID: formID)

        do {
            _ = try await controller.currentSnapshot()
            XCTFail("Expected missing snapshot failure")
        } catch {
            XCTAssertEqual(error as? FormValidationFailure, .missingSnapshot)
        }
    }

}

private actor DelayingFormSnapshotStore: FormSnapshotStore {
    private var snapshots: [FormID: FormSnapshot] = [:]
    private let loadDelayNanoseconds: UInt64

    init(loadDelayNanoseconds: UInt64) {
        self.loadDelayNanoseconds = loadDelayNanoseconds
    }

    func load(formID: FormID) async throws -> FormSnapshot? {
        try await Task.sleep(nanoseconds: loadDelayNanoseconds)
        return snapshots[formID]
    }

    func save(_ snapshot: FormSnapshot) async throws {
        snapshots[snapshot.formID] = snapshot
    }

    func remove(formID: FormID) async throws {
        snapshots.removeValue(forKey: formID)
    }
}
