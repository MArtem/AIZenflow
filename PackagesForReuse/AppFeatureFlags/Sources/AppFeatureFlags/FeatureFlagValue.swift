import Foundation

/// A typed, Codable value used by feature flags, variants, and evaluation contexts.
public enum FeatureFlagValue: Equatable, Codable, Sendable, CustomStringConvertible {
    case bool(Bool)
    case string(String)
    case int(Int)
    case double(Double)
    case stringArray([String])
    case null

    private enum CodingKeys: String, CodingKey {
        case type
        case boolValue
        case stringValue
        case intValue
        case doubleValue
        case stringArrayValue
    }

    private enum ValueType: String, Codable {
        case bool
        case string
        case int
        case double
        case stringArray
        case null
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ValueType.self, forKey: .type)
        switch type {
        case .bool:
            self = .bool(try container.decode(Bool.self, forKey: .boolValue))
        case .string:
            self = .string(try container.decode(String.self, forKey: .stringValue))
        case .int:
            self = .int(try container.decode(Int.self, forKey: .intValue))
        case .double:
            self = .double(try container.decode(Double.self, forKey: .doubleValue))
        case .stringArray:
            self = .stringArray(try container.decode([String].self, forKey: .stringArrayValue))
        case .null:
            self = .null
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .bool(let value):
            try container.encode(ValueType.bool, forKey: .type)
            try container.encode(value, forKey: .boolValue)
        case .string(let value):
            try container.encode(ValueType.string, forKey: .type)
            try container.encode(value, forKey: .stringValue)
        case .int(let value):
            try container.encode(ValueType.int, forKey: .type)
            try container.encode(value, forKey: .intValue)
        case .double(let value):
            try container.encode(ValueType.double, forKey: .type)
            try container.encode(value, forKey: .doubleValue)
        case .stringArray(let value):
            try container.encode(ValueType.stringArray, forKey: .type)
            try container.encode(value, forKey: .stringArrayValue)
        case .null:
            try container.encode(ValueType.null, forKey: .type)
        }
    }

    public var boolValue: Bool? {
        guard case .bool(let value) = self else { return nil }
        return value
    }

    public var stringValue: String? {
        guard case .string(let value) = self else { return nil }
        return value
    }

    public var intValue: Int? {
        guard case .int(let value) = self else { return nil }
        return value
    }

    public var doubleValue: Double? {
        switch self {
        case .double(let value): return value
        case .int(let value): return Double(value)
        default: return nil
        }
    }

    public var description: String {
        switch self {
        case .bool(let value): return String(value)
        case .string: return "<string>"
        case .int(let value): return String(value)
        case .double(let value): return String(value)
        case .stringArray(let value): return "<string_array:\(value.count)>"
        case .null: return "null"
        }
    }

    /// Returns the raw string only for call sites that explicitly need user/application-visible data.
    /// Do not use this for telemetry, logs, or diagnostics.
    public var rawStringForDisplay: String? {
        guard case .string(let value) = self else { return nil }
        return value
    }
}
