public struct InputFormattingResult: Sendable, Hashable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public let fieldID: InputFieldID
    public let text: String
    public let selection: InputTextSelection
    public let appliedFormatterCount: Int
    public let revision: UInt64

    public init(
        fieldID: InputFieldID,
        text: String,
        selection: InputTextSelection,
        appliedFormatterCount: Int,
        revision: UInt64
    ) throws {
        guard appliedFormatterCount >= 0 else {
            throw InputFormattingFailure.invalidLimit
        }
        self.fieldID = fieldID
        self.text = text
        self.selection = try selection.validated(for: text)
        self.appliedFormatterCount = appliedFormatterCount
        self.revision = revision
    }

    public func asSnapshot() throws -> InputSnapshot {
        try InputSnapshot(fieldID: fieldID, text: text, selection: selection, revision: revision)
    }

    public var description: String {
        "InputFormattingResult(field:\(fieldID),textLength:\(text.count),applied:\(appliedFormatterCount),revision:\(revision))"
    }

    public var debugDescription: String { description }
}
