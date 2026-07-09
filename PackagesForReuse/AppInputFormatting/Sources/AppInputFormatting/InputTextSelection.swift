public struct InputTextSelection: Sendable, Hashable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public let lowerCharacterOffset: Int
    public let upperCharacterOffset: Int

    public init(lowerCharacterOffset: Int, upperCharacterOffset: Int) throws {
        guard lowerCharacterOffset >= 0, upperCharacterOffset >= lowerCharacterOffset else {
            throw InputFormattingFailure.invalidSelection
        }
        self.lowerCharacterOffset = lowerCharacterOffset
        self.upperCharacterOffset = upperCharacterOffset
    }

    public static func caret(at characterOffset: Int) throws -> InputTextSelection {
        try InputTextSelection(lowerCharacterOffset: characterOffset, upperCharacterOffset: characterOffset)
    }

    public var isCaret: Bool {
        lowerCharacterOffset == upperCharacterOffset
    }

    public func validated(for text: String) throws -> InputTextSelection {
        guard upperCharacterOffset <= text.count else {
            throw InputFormattingFailure.invalidSelection
        }
        return self
    }

    public var description: String {
        "InputTextSelection(rangeLength:\(upperCharacterOffset - lowerCharacterOffset))"
    }

    public var debugDescription: String { description }
}
