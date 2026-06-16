public struct RateLimitKey: Hashable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public static let maximumLength = 128

    public let value: String

    public init(_ value: String) throws {
        guard value.isEmpty == false else {
            throw RateLimitFailure.emptyKey
        }
        guard value.count <= Self.maximumLength else {
            throw RateLimitFailure.keyTooLong(maximumLength: Self.maximumLength)
        }
        guard value.unicodeScalars.allSatisfy(Self.isAllowedScalar(_:)) else {
            throw RateLimitFailure.unsafeKeyCharacter
        }
        self.value = value
    }

    public var description: String {
        "RateLimitKey(redacted,length:\(value.count))"
    }

    public var debugDescription: String {
        description
    }

    private static func isAllowedScalar(_ scalar: UnicodeScalar) -> Bool {
        switch scalar.value {
        case 48...57, 65...90, 97...122:
            return true
        case 45, 46, 58, 95:
            return true
        default:
            return false
        }
    }
}
