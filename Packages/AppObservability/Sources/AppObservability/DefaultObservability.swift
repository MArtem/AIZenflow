import Foundation

public struct DefaultObservability: ObservabilityManaging {
    private let recorder: any ObservabilityRecording
    private let clock: any ObservabilityClock
    private let idGenerator: any ObservabilityIDGenerating
    private let redactor: ObservabilityRedactor

    public init(
        recorder: any ObservabilityRecording = NoopObservabilityRecorder(),
        clock: any ObservabilityClock = SystemObservabilityClock(),
        idGenerator: any ObservabilityIDGenerating = UUIDObservabilityIDGenerator(),
        redactor: ObservabilityRedactor = ObservabilityRedactor()
    ) {
        self.recorder = recorder
        self.clock = clock
        self.idGenerator = idGenerator
        self.redactor = redactor
    }

    /// Starts a span using caller-provided propagation state only.
    ///
    /// Correlation IDs are caller-owned: the package reuses `diagnosticContext.correlationID`
    /// or `parent.correlationID` when present and otherwise leaves the span correlation ID `nil`.
    public func startSpan(
        _ name: String,
        parent: TraceContext? = nil,
        attributes: ObservabilityAttributes = [:],
        diagnosticContext: DiagnosticContext? = nil
    ) async -> ObservabilitySpan {
        let traceID = parent?.traceID ?? idGenerator.makeTraceID()
        let spanID = idGenerator.makeSpanID()
        let correlationID = diagnosticContext?.correlationID ?? parent?.correlationID
        let startedAt = clock.now()
        let mergedAttributes = (parent?.baggage ?? [:])
            .mergingObservabilityAttributes(diagnosticContext?.attributes ?? [:])
            .mergingObservabilityAttributes(attributes)
        let redactedAttributes = redactor.redact(mergedAttributes)

        let event = ObservabilityEvent(
            kind: .spanStarted,
            name: name,
            timestamp: startedAt,
            traceID: traceID,
            spanID: spanID,
            parentSpanID: parent?.spanID,
            correlationID: correlationID,
            status: .running,
            attributes: redactedAttributes
        )
        await recorder.record(event)

        return ObservabilitySpan(
            name: name,
            traceID: traceID,
            spanID: spanID,
            parentSpanID: parent?.spanID,
            correlationID: correlationID,
            startedAt: startedAt,
            attributes: redactedAttributes,
            recorder: recorder,
            clock: clock,
            redactor: redactor
        )
    }

    public func addBreadcrumb(
        _ name: String,
        attributes: ObservabilityAttributes = [:],
        diagnosticContext: DiagnosticContext? = nil
    ) async {
        let mergedAttributes = (diagnosticContext?.attributes ?? [:]).mergingObservabilityAttributes(attributes)
        let event = ObservabilityEvent(
            kind: .breadcrumb,
            name: name,
            timestamp: clock.now(),
            correlationID: diagnosticContext?.correlationID,
            attributes: redactor.redact(mergedAttributes)
        )
        await recorder.record(event)
    }

    /// Measures an async operation without exposing raw error text.
    ///
    /// `CancellationError` is recorded as `.cancelled`. Other failures use structured
    /// `ObservabilityErrorDescriptor` data when available and fall back to `operation_failed`.
    public func measure<T: Sendable>(
        _ name: String,
        attributes: ObservabilityAttributes = [:],
        diagnosticContext: DiagnosticContext? = nil,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        let startedAt = clock.now()
        let mergedAttributes = (diagnosticContext?.attributes ?? [:]).mergingObservabilityAttributes(attributes)

        do {
            let result = try await operation()
            let endedAt = clock.now()
            await recorder.record(
                ObservabilityEvent(
                    kind: .measurement,
                    name: name,
                    timestamp: endedAt,
                    correlationID: diagnosticContext?.correlationID,
                    durationSeconds: max(0, endedAt.timeIntervalSince(startedAt)),
                    status: .ok,
                    attributes: redactor.redact(mergedAttributes)
                )
            )
            return result
        } catch let error as CancellationError {
            let endedAt = clock.now()
            await recorder.record(
                ObservabilityEvent(
                    kind: .measurement,
                    name: name,
                    timestamp: endedAt,
                    correlationID: diagnosticContext?.correlationID,
                    durationSeconds: max(0, endedAt.timeIntervalSince(startedAt)),
                    status: .cancelled,
                    attributes: redactor.redact(mergedAttributes)
                )
            )
            throw error
        } catch {
            let endedAt = clock.now()
            let descriptor = (error as? any ObservabilityErrorDescribing)?.observabilityErrorDescriptor ?? .operationFailed
            await recorder.record(
                ObservabilityEvent(
                    kind: .measurement,
                    name: name,
                    timestamp: endedAt,
                    correlationID: diagnosticContext?.correlationID,
                    durationSeconds: max(0, endedAt.timeIntervalSince(startedAt)),
                    status: .failed(descriptor),
                    attributes: redactor.redact(mergedAttributes)
                )
            )
            throw error
        }
    }
}
