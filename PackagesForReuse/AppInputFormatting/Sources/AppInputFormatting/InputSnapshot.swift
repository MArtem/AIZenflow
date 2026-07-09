public struct InputSnapshot: Sendable, Hashable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public let fieldID: InputFieldID
    public let text: String
    public let selection: InputTextSelection
    public let revision: UInt64

    public init(
        fieldID: InputFieldID,
        text: String,
        selection: InputTextSelection,
        revision: UInt64 = 0
    ) throws {
        self.fieldID = fieldID
        self.text = text
        self.selection = try selection.validated(for: text)
        self.revision = revision
    }

    public var description: String {
        "InputSnapshot(field:\(fieldID),textLength:\(text.count),revision:\(revision))"
    }

    public var debugDescription: String { description }
}
