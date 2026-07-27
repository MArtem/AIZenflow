import Foundation

public struct SafeInputIdentifier: Sendable, Hashable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public let value: String

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed == value else {
            throw InputFormattingFailure.invalidIdentifier
        }
        guard (1...96).contains(value.count) else {
            throw InputFormattingFailure.invalidIdentifier
        }
        guard value.allSatisfy(Self.isAllowedCharacter(_:)) else {
            throw InputFormattingFailure.invalidIdentifier
        }
        guard value.first?.isLetter == true else {
            throw InputFormattingFailure.invalidIdentifier
        }
        self.value = value
    }

    public var description: String {
        "SafeInputIdentifier(redacted,length:\(value.count))"
    }

    public var debugDescription: String { description }

    private static func isAllowedCharacter(_ character: Character) -> Bool {
        character.isLetter || character.isNumber || character == "." || character == "_" || character == "-"
    }
}
