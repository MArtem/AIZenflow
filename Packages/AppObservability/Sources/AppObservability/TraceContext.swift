import Foundation

/// Caller-owned trace propagation state.
///
/// `AppObservability` reuses `correlationID` only when callers provide a parent `TraceContext`
/// or `DiagnosticContext`; it does not synthesize one during span creation.
public struct TraceContext: Codable, Hashable, Sendable {
    public let traceID: TraceID
    public let spanID: SpanID?
    public let correlationID: CorrelationID?
    public let baggage: ObservabilityAttributes

    public init(
        traceID: TraceID,
        spanID: SpanID? = nil,
        correlationID: CorrelationID? = nil,
        baggage: ObservabilityAttributes = [:]
    ) {
        self.traceID = traceID
        self.spanID = spanID
        self.correlationID = correlationID
        self.baggage = baggage
    }

    public func childContext(spanID: SpanID) -> TraceContext {
        TraceContext(
            traceID: traceID,
            spanID: spanID,
            correlationID: correlationID,
            baggage: baggage
        )
    }

    public func mergingBaggage(_ attributes: ObservabilityAttributes) -> TraceContext {
        TraceContext(
            traceID: traceID,
            spanID: spanID,
            correlationID: correlationID,
            baggage: baggage.mergingObservabilityAttributes(attributes)
        )
    }
}
