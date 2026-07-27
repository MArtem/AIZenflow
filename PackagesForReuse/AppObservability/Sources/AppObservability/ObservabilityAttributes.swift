import Foundation

public enum ObservabilityPrivacy: String, Codable, Hashable, Sendable {
    case `public`
    case `private`
    case sensitive
}

public enum ObservabilityValue: Codable, Hashable, Sendable, CustomStringConvertible {
    case string(String)
    case integer(Int)
    case double(Double)
    case bool(Bool)
    case date(Date)
    case stringArray([String])

    public var description: String {
        switch self {
        case .string: "<string>"
        case .integer(let value): String(value)
        case .double(let value): String(value)
        case .bool(let value): String(value)
        case .date(let value): ISO8601DateFormatter().string(from: value)
        case .stringArray(let values): "<string_array:\(values.count)>"
        }
    }

    /// Returns the raw string only for call sites that explicitly need user/application-visible data.
    /// Do not use this for telemetry exporters, logs, or diagnostics.
    public var rawStringForDisplay: String? {
        guard case .string(let value) = self else { return nil }
        return value
    }
}

public struct ObservabilityAttribute: Codable, Hashable, Sendable {
    public let value: ObservabilityValue
    public let privacy: ObservabilityPrivacy

    public init(_ value: ObservabilityValue, privacy: ObservabilityPrivacy = .public) {
        self.value = value
        self.privacy = privacy
    }

    public static func string(_ value: String, privacy: ObservabilityPrivacy = .public) -> ObservabilityAttribute {
        ObservabilityAttribute(.string(value), privacy: privacy)
    }

    public static func integer(_ value: Int, privacy: ObservabilityPrivacy = .public) -> ObservabilityAttribute {
        ObservabilityAttribute(.integer(value), privacy: privacy)
    }

    public static func double(_ value: Double, privacy: ObservabilityPrivacy = .public) -> ObservabilityAttribute {
        ObservabilityAttribute(.double(value), privacy: privacy)
    }

    public static func bool(_ value: Bool, privacy: ObservabilityPrivacy = .public) -> ObservabilityAttribute {
        ObservabilityAttribute(.bool(value), privacy: privacy)
    }

    public static func date(_ value: Date, privacy: ObservabilityPrivacy = .public) -> ObservabilityAttribute {
        ObservabilityAttribute(.date(value), privacy: privacy)
    }

    public static func stringArray(_ values: [String], privacy: ObservabilityPrivacy = .public) -> ObservabilityAttribute {
        ObservabilityAttribute(.stringArray(values), privacy: privacy)
    }
}

public typealias ObservabilityAttributes = [String: ObservabilityAttribute]

public extension Dictionary where Key == String, Value == ObservabilityAttribute {
    func mergingObservabilityAttributes(_ other: ObservabilityAttributes) -> ObservabilityAttributes {
        merging(other) { _, new in new }
    }
}
