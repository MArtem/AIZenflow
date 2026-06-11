import Foundation

public struct TraceID: RawRepresentable, Codable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static func make() -> TraceID {
        TraceID(rawValue: UUID().uuidString.lowercased())
    }

    public var description: String { rawValue }
}

public struct SpanID: RawRepresentable, Codable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static func make() -> SpanID {
        SpanID(rawValue: UUID().uuidString.lowercased())
    }

    public var description: String { rawValue }
}

public struct CorrelationID: RawRepresentable, Codable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static func make() -> CorrelationID {
        CorrelationID(rawValue: UUID().uuidString.lowercased())
    }

    public var description: String { rawValue }
}

public protocol ObservabilityIDGenerating: Sendable {
    func makeTraceID() -> TraceID
    func makeSpanID() -> SpanID
    func makeCorrelationID() -> CorrelationID
}

public struct UUIDObservabilityIDGenerator: ObservabilityIDGenerating {
    public init() {}

    public func makeTraceID() -> TraceID { .make() }
    public func makeSpanID() -> SpanID { .make() }
    public func makeCorrelationID() -> CorrelationID { .make() }
}
