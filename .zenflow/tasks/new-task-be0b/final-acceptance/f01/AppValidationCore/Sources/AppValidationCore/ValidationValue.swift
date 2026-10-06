import Foundation

public enum ValidationValueKind: String, Codable, Sendable {
    case text
    case integer
    case decimal
    case flag
    case missing
}

public enum ValidationValue: Equatable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    case text(String)
    case integer(Int)
    case decimal(Double)
    case flag(Bool)
    case missing

    public var kind: ValidationValueKind {
        switch self {
        case .text:
            return .text
        case .integer:
            return .integer
        case .decimal:
            return .decimal
        case .flag:
            return .flag
        case .missing:
            return .missing
        }
    }

    public var isEmptyLike: Bool {
        switch self {
        case .text(let value):
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .missing:
            return true
        case .integer, .decimal, .flag:
            return false
        }
    }

    public var description: String {
        "ValidationValue(kind: \(kind), value: redacted)"
    }

    public var debugDescription: String {
        description
    }
}

public struct NamedValidationValue: Equatable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let id: ValidationValueID
    public let value: ValidationValue

    public init(id: ValidationValueID, value: ValidationValue) {
        self.id = id
        self.value = value
    }

    public var description: String {
        "NamedValidationValue(id: redacted, kind: \(value.kind))"
    }

    public var debugDescription: String {
        description
    }
}
