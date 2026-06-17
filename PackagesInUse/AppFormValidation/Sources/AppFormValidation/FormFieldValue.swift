import Foundation

public enum FormFieldValue: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    case empty
    case string(String)
    case bool(Bool)
    case integer(Int)
    case decimal(Double)

    public var isEmptyForValidation: Bool {
        switch self {
        case .empty:
            return true
        case .string(let value):
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .bool, .integer, .decimal:
            return false
        }
    }

    public var stringCountForValidation: Int? {
        switch self {
        case .string(let value):
            return value.count
        case .empty, .bool, .integer, .decimal:
            return nil
        }
    }

    public var description: String {
        switch self {
        case .empty:
            return "<redacted:value-kind:empty>"
        case .string(let value):
            return "<redacted:value-kind:string,length:\(value.count)>"
        case .bool:
            return "<redacted:value-kind:bool>"
        case .integer:
            return "<redacted:value-kind:integer>"
        case .decimal:
            return "<redacted:value-kind:decimal>"
        }
    }

    public var debugDescription: String { description }
}
