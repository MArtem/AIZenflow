import Foundation

public protocol SafeFormIdentifier: Codable, Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    var rawValue: String { get }
    init(_ rawValue: String) throws
}

extension SafeFormIdentifier {
    public var description: String {
        "<redacted:\(Self.self),length:\(rawValue.count)>"
    }

    public var debugDescription: String { description }
}

enum SafeFormIdentifierValidator {
    static func validate(_ value: String, label: String, maximumLength: Int = 160) throws {
        guard !value.isEmpty else {
            throw FormValidationFailure.invalidIdentifier(label: label, reason: .empty)
        }
        guard value.count <= maximumLength else {
            throw FormValidationFailure.invalidIdentifier(label: label, reason: .tooLong(maximum: maximumLength))
        }
        guard value.allSatisfy(isAllowedCharacter) else {
            throw FormValidationFailure.invalidIdentifier(label: label, reason: .containsUnsafeCharacters)
        }
    }

    private static func isAllowedCharacter(_ character: Character) -> Bool {
        character.isASCII && (character.isLetter || character.isNumber || character == "." || character == "_" || character == "-")
    }
}
