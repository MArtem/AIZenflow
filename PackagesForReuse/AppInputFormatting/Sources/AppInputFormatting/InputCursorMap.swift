public struct InputCursorMap: Sendable, Hashable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public let originalLength: Int
    public let formattedLength: Int
    private let formattedOffsets: [Int]

    public init(originalLength: Int, formattedLength: Int, formattedOffsets: [Int]) throws {
        guard originalLength >= 0, formattedLength >= 0 else {
            throw InputFormattingFailure.invalidSelection
        }
        guard formattedOffsets.count == originalLength + 1 else {
            throw InputFormattingFailure.invalidSelection
        }
        guard formattedOffsets.allSatisfy({ $0 >= 0 && $0 <= formattedLength }) else {
            throw InputFormattingFailure.invalidSelection
        }
        self.originalLength = originalLength
        self.formattedLength = formattedLength
        self.formattedOffsets = formattedOffsets
    }

    public static func identity(length: Int) throws -> InputCursorMap {
        try InputCursorMap(
            originalLength: length,
            formattedLength: length,
            formattedOffsets: Array(0...length)
        )
    }

    public func formattedOffset(forOriginalOffset offset: Int) -> Int {
        let bounded = min(max(offset, 0), originalLength)
        return formattedOffsets[bounded]
    }

    public func map(_ selection: InputTextSelection) throws -> InputTextSelection {
        try InputTextSelection(
            lowerCharacterOffset: formattedOffset(forOriginalOffset: selection.lowerCharacterOffset),
            upperCharacterOffset: formattedOffset(forOriginalOffset: selection.upperCharacterOffset)
        )
    }

    public var description: String {
        "InputCursorMap(originalLength:\(originalLength),formattedLength:\(formattedLength))"
    }

    public var debugDescription: String { description }
}
