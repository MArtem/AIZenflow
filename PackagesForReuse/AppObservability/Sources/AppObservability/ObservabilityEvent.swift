import Foundation

public enum ObservabilityEventKind: String, Codable, Hashable, Sendable {
    case spanStarted
    case spanEnded
    case breadcrumb
    case measurement
}

public enum SpanStatus: Codable, Hashable, Sendable {
    case running
    case ok
    case cancelled
    case failed(ObservabilityErrorDescriptor)
}

public struct ObservabilityEvent: Codable, Hashable, Sendable {
    public let id: String
    public let kind: ObservabilityEventKind
    /// Stable taxonomy key for a span, breadcrumb, or measurement. Do not build names from user input, raw URLs, emails, tokens, or high-cardinality identifiers.
    public let name: String
    public let timestamp: Date
    public let traceID: TraceID?
    public let spanID: SpanID?
    public let parentSpanID: SpanID?
    public let correlationID: CorrelationID?
    public let durationSeconds: Double?
    public let status: SpanStatus?
    public let attributes: ObservabilityAttributes

    public init(
        id: String = UUID().uuidString.lowercased(),
        kind: ObservabilityEventKind,
        name: String,
        timestamp: Date,
        traceID: TraceID? = nil,
        spanID: SpanID? = nil,
        parentSpanID: SpanID? = nil,
        correlationID: CorrelationID? = nil,
        durationSeconds: Double? = nil,
        status: SpanStatus? = nil,
        attributes: ObservabilityAttributes = [:]
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.timestamp = timestamp
        self.traceID = traceID
        self.spanID = spanID
        self.parentSpanID = parentSpanID
        self.correlationID = correlationID
        self.durationSeconds = durationSeconds
        self.status = status
        self.attributes = attributes
    }
}
