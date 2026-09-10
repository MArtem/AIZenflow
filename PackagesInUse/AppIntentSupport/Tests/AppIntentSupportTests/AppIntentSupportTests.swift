import Testing
@testable import AppIntentSupport

@Test("required text trims whitespace")
func requiredTextTrimsWhitespace() throws {
    let input = try AppIntentTextInput(
        "  Create a card  ",
        fieldName: "title"
    )

    #expect(input.value == "Create a card")
}

@Test("required text rejects empty normalized values")
func requiredTextRejectsEmptyValues() {
    do {
        _ = try AppIntentTextInput(" \n\t ", fieldName: "title")
        Issue.record("Expected empty required text to fail")
    } catch let failure as AppIntentSupportValidationFailure {
        #expect(failure == .emptyRequiredText(fieldName: "title"))
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}

@Test("maximum character count is inclusive and counts characters")
func maximumCharacterCountIsInclusive() throws {
    let exact = try AppIntentTextInput(
        "🙂🙂",
        fieldName: "title",
        maximumCharacterCount: 2
    )
    #expect(exact.value == "🙂🙂")

    do {
        _ = try AppIntentTextInput(
            "🙂🙂🙂",
            fieldName: "title",
            maximumCharacterCount: 2
        )
        Issue.record("Expected over-limit text to fail")
    } catch let failure as AppIntentSupportValidationFailure {
        #expect(
            failure == .textExceedsLimit(
                fieldName: "title",
                maximumCharacterCount: 2
            )
        )
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}

@Test("normalizer delegates to the same validation contract")
func normalizerDelegatesToValidationContract() throws {
    let normalized = try AppIntentTextNormalizer.requiredText(
        "  note  ",
        fieldName: "body",
        maximumCharacterCount: 4
    )
    #expect(normalized == "note")
}
