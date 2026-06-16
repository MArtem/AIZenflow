import Foundation

public protocol SafeStateMachineIdentifier: Codable, Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    var rawValue: String { get }
    init(_ rawValue: String) throws
}

extension SafeStateMachineIdentifier {
    public var description: String {
        "<redacted:\(Self.self),length:\(rawValue.count)>"
    }

    public var debugDescription: String { description }
}

enum SafeIdentifierValidator {
    static func validate(_ value: String, label: String) throws {
        guard !value.isEmpty else {
            throw StateMachineFailure.invalidIdentifier(label: label, reason: .empty)
        }
        guard value.count <= 128 else {
            throw StateMachineFailure.invalidIdentifier(label: label, reason: .tooLong(maximum: 128))
        }
        guard value.allSatisfy(isAllowedCharacter) else {
            throw StateMachineFailure.invalidIdentifier(label: label, reason: .containsUnsafeCharacters)
        }
    }

    private static func isAllowedCharacter(_ character: Character) -> Bool {
        character.isASCII && (character.isLetter || character.isNumber || character == "." || character == "_" || character == "-")
    }
}
