import Foundation

private actor SpanEndState {
    private var hasEnded = false

    func beginEnding() -> Bool {
        guard !hasEnded else {
            return false
        }
        hasEnded = true
        return true
    }
}

public struct ObservabilitySpan: Sendable {
    public let name: String
    public let traceID: TraceID
    public let spanID: SpanID
    public let parentSpanID: SpanID?
    public let correlationID: CorrelationID?
    public let startedAt: Date
    public let attributes: ObservabilityAttributes

    private let recorder: any ObservabilityRecording
    private let clock: any ObservabilityClock
    private let redactor: ObservabilityRedactor
    private let endState: SpanEndState

    public init(
        name: String,
        traceID: TraceID,
        spanID: SpanID,
        parentSpanID: SpanID? = nil,
        correlationID: CorrelationID? = nil,
        startedAt: Date,
        attributes: ObservabilityAttributes = [:],
        recorder: any ObservabilityRecording,
        clock: any ObservabilityClock = SystemObservabilityClock(),
        redactor: ObservabilityRedactor = ObservabilityRedactor()
    ) {
        self.name = name
        self.traceID = traceID
        self.spanID = spanID
        self.parentSpanID = parentSpanID
        self.correlationID = correlationID
        self.startedAt = startedAt
        self.attributes = attributes
        self.recorder = recorder
        self.clock = clock
        self.redactor = redactor
        self.endState = SpanEndState()
    }

    public var traceContext: TraceContext {
        TraceContext(
            traceID: traceID,
            spanID: spanID,
            correlationID: correlationID,
            baggage: attributes
        )
    }

    /// Ends the span at most once. Repeated calls are ignored.
    public func end(
        status: SpanStatus = .ok,
        attributes endAttributes: ObservabilityAttributes = [:]
    ) async {
        guard await endState.beginEnding() else {
            return
        }

        let endedAt = clock.now()
        let merged = attributes.mergingObservabilityAttributes(endAttributes)
        let event = ObservabilityEvent(
            kind: .spanEnded,
            name: name,
            timestamp: endedAt,
            traceID: traceID,
            spanID: spanID,
            parentSpanID: parentSpanID,
            correlationID: correlationID,
            durationSeconds: max(0, endedAt.timeIntervalSince(startedAt)),
            status: status,
            attributes: redactor.redact(merged)
        )
        await recorder.record(event)
    }
}
