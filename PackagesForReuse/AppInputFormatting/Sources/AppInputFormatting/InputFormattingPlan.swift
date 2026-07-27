public struct InputFormattingPlan: Sendable, Hashable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public let fieldID: InputFieldID
    public let formatterIDs: [InputFormatterID]

    public init(fieldID: InputFieldID, formatterIDs: [InputFormatterID]) throws {
        guard !formatterIDs.isEmpty else {
            throw InputFormattingFailure.missingFormatter
        }
        guard formatterIDs.count <= 128 else {
            throw InputFormattingFailure.invalidLimit
        }
        guard Set(formatterIDs).count == formatterIDs.count else {
            throw InputFormattingFailure.duplicateFormatter
        }
        self.fieldID = fieldID
        self.formatterIDs = formatterIDs
    }

    public var description: String {
        "InputFormattingPlan(field:\(fieldID),formatterCount:\(formatterIDs.count))"
    }

    public var debugDescription: String { description }
}
