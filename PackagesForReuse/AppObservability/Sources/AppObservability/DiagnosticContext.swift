import Foundation

/// Caller-owned diagnostic context for observability events.
///
/// `AppObservability` does not auto-generate or persist correlation IDs outside this value.
/// If callers want a shared correlation ID, they must provide it explicitly via `DiagnosticContext`
/// or `TraceContext`.
public struct DiagnosticContext: Codable, Hashable, Sendable {
    public let correlationID: CorrelationID
    public let attributes: ObservabilityAttributes

    public init(
        correlationID: CorrelationID = .make(),
        attributes: ObservabilityAttributes = [:]
    ) {
        self.correlationID = correlationID
        self.attributes = attributes
    }

    public func setting(_ attribute: ObservabilityAttribute, forKey key: String) -> DiagnosticContext {
        var next = attributes
        next[key] = attribute
        return DiagnosticContext(correlationID: correlationID, attributes: next)
    }

    public func merging(_ other: ObservabilityAttributes) -> DiagnosticContext {
        DiagnosticContext(
            correlationID: correlationID,
            attributes: attributes.mergingObservabilityAttributes(other)
        )
    }
}
