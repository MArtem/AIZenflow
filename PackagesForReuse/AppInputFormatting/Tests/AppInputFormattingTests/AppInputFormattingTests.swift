import XCTest
@testable import AppInputFormatting

final class AppInputFormattingTests: XCTestCase {
    func testSafeIdentifiersRejectUnsafeInput() throws {
        XCTAssertThrowsError(try InputFieldID(" field"))
        XCTAssertThrowsError(try InputFieldID("1field"))
        XCTAssertThrowsError(try InputFormatterID("field/value"))
        let id = try InputFieldID("checkout.cardNumber")
        XCTAssertFalse(id.description.contains("checkout.cardNumber"))
    }

    func testDigitsOnlyFormatsTextAndMapsCaret() async throws {
        let fieldID = try InputFieldID("phone")
        let formatterID = try InputFormatterID("digits")
        let formatter = try BuiltInInputFormatter(id: formatterID, kind: .allowDecimalDigits)
        let snapshot = try InputSnapshot(
            fieldID: fieldID,
            text: "12a3-4",
            selection: .caret(at: 6)
        )

        let result = try await formatter.format(snapshot)

        XCTAssertEqual(result.text, "1234")
        XCTAssertEqual(result.selection.lowerCharacterOffset, 4)
        XCTAssertEqual(result.appliedFormatterCount, 1)
        XCTAssertFalse(result.description.contains("1234"))
    }

    func testWhitespaceFormattersCanBePipelined() async throws {
        let fieldID = try InputFieldID("name")
        let trimID = try InputFormatterID("trim")
        let collapseID = try InputFormatterID("collapse")
        let pipelineID = try InputFormatterID("name.pipeline")
        let pipeline = try InputFormattingPipeline(
            id: pipelineID,
            formatters: [
                try BuiltInInputFormatter(id: trimID, kind: .trimEdges),
                try BuiltInInputFormatter(id: collapseID, kind: .collapseWhitespace)
            ]
        )
        let snapshot = try InputSnapshot(
            fieldID: fieldID,
            text: "  Ada    Lovelace  ",
            selection: .caret(at: 19)
        )

        let result = try await pipeline.format(snapshot)

        XCTAssertEqual(result.text, "Ada Lovelace")
        XCTAssertEqual(result.selection.lowerCharacterOffset, 12)
        XCTAssertEqual(result.appliedFormatterCount, 2)
    }

    func testPatternFormatterUsesMarkerWithoutRevealingPattern() async throws {
        let fieldID = try InputFieldID("phone")
        let formatterID = try InputFormatterID("phonePattern")
        let pattern = try InputFormatPattern("+### (###) ##-##")
        let formatter = try BuiltInInputFormatter(id: formatterID, kind: .pattern(pattern))
        let snapshot = try InputSnapshot(
            fieldID: fieldID,
            text: "1234567890",
            selection: .caret(at: 10)
        )

        let result = try await formatter.format(snapshot)

        XCTAssertEqual(result.text, "+123 (456) 78-90")
        XCTAssertEqual(result.selection.lowerCharacterOffset, 16)
        XCTAssertFalse(pattern.description.contains("+###"))
        XCTAssertFalse(formatter.description.contains("+###"))
    }

    func testEngineLoadsPlanAndFormattersFromStore() async throws {
        let fieldID = try InputFieldID("card")
        let digitsID = try InputFormatterID("digits")
        let groupID = try InputFormatterID("group")
        let store = InMemoryInputFormattingStore()
        try await store.save(formatter: try BuiltInInputFormatter(id: digitsID, kind: .allowDecimalDigits))
        try await store.save(formatter: try BuiltInInputFormatter(id: groupID, kind: .grouped(groupSize: 4, separator: " ")))
        try await store.save(plan: try InputFormattingPlan(fieldID: fieldID, formatterIDs: [digitsID, groupID]))
        let engine = AppInputFormattingEngine(store: store)
        let snapshot = try InputSnapshot(
            fieldID: fieldID,
            text: "4111-1111-1111-1111",
            selection: .caret(at: 19)
        )

        let result = try await engine.format(snapshot)

        XCTAssertEqual(result.text, "4111 1111 1111 1111")
        XCTAssertEqual(result.appliedFormatterCount, 2)
    }

    func testMissingPlanFailsExplicitly() async throws {
        let fieldID = try InputFieldID("unknown")
        let store = InMemoryInputFormattingStore()
        let engine = AppInputFormattingEngine(store: store)
        let snapshot = try InputSnapshot(fieldID: fieldID, text: "value", selection: .caret(at: 5))

        do {
            _ = try await engine.format(snapshot)
            XCTFail("Expected missing plan failure")
        } catch let failure as InputFormattingFailure {
            XCTAssertEqual(failure, .missingPlan)
        }
    }

    func testDuplicateFormatterInPlanFails() throws {
        let fieldID = try InputFieldID("field")
        let formatterID = try InputFormatterID("formatter")
        XCTAssertThrowsError(try InputFormattingPlan(fieldID: fieldID, formatterIDs: [formatterID, formatterID]))
    }

    func testMaxLengthAndCaseFormatting() async throws {
        let fieldID = try InputFieldID("code")
        let upperID = try InputFormatterID("upper")
        let limitID = try InputFormatterID("limit")
        let pipelineID = try InputFormatterID("code.pipeline")
        let pipeline = try InputFormattingPipeline(
            id: pipelineID,
            formatters: [
                try BuiltInInputFormatter(id: upperID, kind: .uppercaseASCII),
                try BuiltInInputFormatter(id: limitID, kind: .maxLength(4))
            ]
        )
        let snapshot = try InputSnapshot(fieldID: fieldID, text: "ab12cd", selection: .caret(at: 6))

        let result = try await pipeline.format(snapshot)

        XCTAssertEqual(result.text, "AB12")
        XCTAssertEqual(result.selection.lowerCharacterOffset, 4)
    }
}

private struct OverflowAppliedFormatter: InputFormatter {
    let id: InputFormatterID

    func format(_ snapshot: InputSnapshot) async throws -> InputFormattingResult {
        try InputFormattingResult(
            fieldID: snapshot.fieldID,
            text: snapshot.text,
            selection: snapshot.selection,
            appliedFormatterCount: Int.max,
            revision: snapshot.revision
        )
    }
}

extension AppInputFormattingTests {
    func testRevisionOverflowFailsExplicitly() async throws {
        let fieldID = try InputFieldID("revision")
        let formatterID = try InputFormatterID("trim")
        let formatter = try BuiltInInputFormatter(id: formatterID, kind: .trimEdges)
        let snapshot = try InputSnapshot(
            fieldID: fieldID,
            text: "value",
            selection: .caret(at: 5),
            revision: UInt64.max
        )

        do {
            _ = try await formatter.format(snapshot)
            XCTFail("Expected revision overflow failure")
        } catch let failure as InputFormattingFailure {
            XCTAssertEqual(failure, .revisionOverflow)
        }
    }

    func testUnsafeFormatterCollectionSizesFail() throws {
        let fieldID = try InputFieldID("field")
        let formatterIDs = try (0..<129).map { try InputFormatterID("formatter.\($0)") }
        XCTAssertThrowsError(try InputFormattingPlan(fieldID: fieldID, formatterIDs: formatterIDs))

        let formatters = try formatterIDs.map {
            try BuiltInInputFormatter(id: $0, kind: .trimEdges)
        }
        XCTAssertThrowsError(try InputFormattingPipeline(id: try InputFormatterID("pipeline"), formatters: formatters))
    }

    func testUnsafeBuiltInFormatterLimitsFail() throws {
        let formatterID = try InputFormatterID("formatter")
        XCTAssertThrowsError(try BuiltInInputFormatter(id: formatterID, kind: .allowCharacters("")))
        XCTAssertThrowsError(try BuiltInInputFormatter(id: formatterID, kind: .allowCharacters(String(repeating: "a", count: 2_049))))
        XCTAssertThrowsError(try BuiltInInputFormatter(id: formatterID, kind: .grouped(groupSize: 4, separator: "")))
        XCTAssertThrowsError(try BuiltInInputFormatter(id: formatterID, kind: .grouped(groupSize: 4, separator: String(repeating: "-", count: 17))))
    }

    func testAppliedFormatterCountOverflowFails() async throws {
        let fieldID = try InputFieldID("field")
        let first = OverflowAppliedFormatter(id: try InputFormatterID("first"))
        let second = OverflowAppliedFormatter(id: try InputFormatterID("second"))
        let pipeline = try InputFormattingPipeline(
            id: try InputFormatterID("pipeline"),
            formatters: [first, second]
        )
        let snapshot = try InputSnapshot(fieldID: fieldID, text: "value", selection: .caret(at: 5))

        do {
            _ = try await pipeline.format(snapshot)
            XCTFail("Expected applied count overflow failure")
        } catch let failure as InputFormattingFailure {
            XCTAssertEqual(failure, .invalidLimit)
        }
    }
}
