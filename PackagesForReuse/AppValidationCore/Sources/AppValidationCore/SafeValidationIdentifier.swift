import Foundation

public struct SafeValidationIdentifier: Hashable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    private let storage: String

    public init(_ value: String) throws {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else {
            throw ValidationFailure.invalidIdentifier(reason: .empty)
        }
        guard normalized.count <= 96 else {
            throw ValidationFailure.invalidIdentifier(reason: .tooLong(maximum: 96))
        }
        guard normalized.unicodeScalars.allSatisfy(Self.isAllowedScalar(_:)) else {
            throw ValidationFailure.invalidIdentifier(reason: .unsupportedCharacter)
        }
        self.storage = normalized
    }

    public var value: String {
        storage
    }

    public var description: String {
        "SafeValidationIdentifier(redacted)"
    }

    public var debugDescription: String {
        description
    }

    private static func isAllowedScalar(_ scalar: UnicodeScalar) -> Bool {
        CharacterSet.alphanumerics.contains(scalar)
            || scalar == "."
            || scalar == "-"
            || scalar == "_"
            || scalar == ":"
    }
}
