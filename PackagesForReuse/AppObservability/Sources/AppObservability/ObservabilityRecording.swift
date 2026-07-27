import Foundation

public protocol ObservabilityRecording: Sendable {
    func record(_ event: ObservabilityEvent) async
}

public struct NoopObservabilityRecorder: ObservabilityRecording {
    public init() {}
    public func record(_ event: ObservabilityEvent) async {}
}

public actor MemoryObservabilityRecorder: ObservabilityRecording {
    private var storedEvents: [ObservabilityEvent]

    public init(events: [ObservabilityEvent] = []) {
        self.storedEvents = events
    }

    public func record(_ event: ObservabilityEvent) {
        storedEvents.append(event)
    }

    public func events() -> [ObservabilityEvent] {
        storedEvents
    }

    public func events(kind: ObservabilityEventKind) -> [ObservabilityEvent] {
        storedEvents.filter { $0.kind == kind }
    }

    public func removeAll() {
        storedEvents.removeAll()
    }
}

public struct RedactingObservabilityRecorder: ObservabilityRecording {
    private let base: any ObservabilityRecording
    private let redactor: ObservabilityRedactor

    public init(base: any ObservabilityRecording, redactor: ObservabilityRedactor = ObservabilityRedactor()) {
        self.base = base
        self.redactor = redactor
    }

    public func record(_ event: ObservabilityEvent) async {
        let redacted = ObservabilityEvent(
            id: event.id,
            kind: event.kind,
            name: event.name,
            timestamp: event.timestamp,
            traceID: event.traceID,
            spanID: event.spanID,
            parentSpanID: event.parentSpanID,
            correlationID: event.correlationID,
            durationSeconds: event.durationSeconds,
            status: event.status,
            attributes: redactor.redact(event.attributes)
        )
        await base.record(redacted)
    }
}

public struct MultiplexObservabilityRecorder: ObservabilityRecording {
    private let recorders: [any ObservabilityRecording]

    public init(_ recorders: [any ObservabilityRecording]) {
        self.recorders = recorders
    }

    public func record(_ event: ObservabilityEvent) async {
        for recorder in recorders {
            await recorder.record(event)
        }
    }
}
