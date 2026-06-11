import XCTest
@testable import AppObservability

private struct FixedClock: ObservabilityClock {
    let date: Date
    func now() -> Date { date }
}

private struct StepClock: ObservabilityClock {
    let dates: [Date]
    private let index: Counter

    init(_ dates: [Date]) {
        self.dates = dates
        self.index = Counter()
    }

    func now() -> Date {
        let current = index.next()
        return dates[min(current, dates.count - 1)]
    }
}

private final class Counter: @unchecked Sendable {
    private var value = 0
    private let lock = NSLock()

    func next() -> Int {
        lock.lock()
        defer { lock.unlock() }
        let current = value
        value += 1
        return current
    }
}

private struct FixedIDGenerator: ObservabilityIDGenerating {
    func makeTraceID() -> TraceID { TraceID(rawValue: "trace-1") }
    func makeSpanID() -> SpanID { SpanID(rawValue: "span-1") }
    func makeCorrelationID() -> CorrelationID { CorrelationID(rawValue: "corr-1") }
}

private enum TestFailure: Error, ObservabilityErrorDescribing {
    case offline

    var observabilityErrorDescriptor: ObservabilityErrorDescriptor {
        ObservabilityErrorDescriptor(category: .network, code: "offline", isRetryable: true)
    }
}

final class AppObservabilityTests: XCTestCase {
    func testStartSpanRecordsSpanStartedEvent() async {
        let recorder = MemoryObservabilityRecorder()
        let observability = DefaultObservability(
            recorder: recorder,
            clock: FixedClock(date: Date(timeIntervalSince1970: 100)),
            idGenerator: FixedIDGenerator()
        )

        let span = await observability.startSpan("feed.load", attributes: [
            "source": .string("remote")
        ])

        let events = await recorder.events()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].kind, .spanStarted)
        XCTAssertEqual(events[0].name, "feed.load")
        XCTAssertEqual(events[0].traceID, TraceID(rawValue: "trace-1"))
        XCTAssertEqual(events[0].spanID, SpanID(rawValue: "span-1"))
        XCTAssertEqual(events[0].status, .running)
        XCTAssertNil(events[0].correlationID)
        XCTAssertEqual(events[0].attributes["source"], .string("remote"))
        XCTAssertEqual(span.traceID, TraceID(rawValue: "trace-1"))
        XCTAssertNil(span.correlationID)
    }

    func testEndingSpanRecordsDurationAndStatus() async {
        let recorder = MemoryObservabilityRecorder()
        let clock = StepClock([
            Date(timeIntervalSince1970: 10),
            Date(timeIntervalSince1970: 12.5)
        ])
        let observability = DefaultObservability(
            recorder: recorder,
            clock: clock,
            idGenerator: FixedIDGenerator()
        )

        let span = await observability.startSpan("sync.run")
        await span.end(status: .ok, attributes: ["items": .integer(5)])

        let events = await recorder.events()
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[1].kind, .spanEnded)
        XCTAssertEqual(events[1].status, .ok)
        XCTAssertEqual(events[1].durationSeconds ?? -1, 2.5, accuracy: 0.001)
        XCTAssertEqual(events[1].attributes["items"], .integer(5))
    }

    func testChildSpanInheritsTraceAndUsesParentSpanID() async {
        let recorder = MemoryObservabilityRecorder()
        let observability = DefaultObservability(
            recorder: recorder,
            clock: FixedClock(date: Date(timeIntervalSince1970: 1)),
            idGenerator: FixedIDGenerator()
        )
        let parent = TraceContext(
            traceID: TraceID(rawValue: "existing-trace"),
            spanID: SpanID(rawValue: "parent-span"),
            correlationID: CorrelationID(rawValue: "corr-parent"),
            baggage: ["feature": .string("feed")]
        )

        _ = await observability.startSpan("feed.child", parent: parent, attributes: [
            "page": .integer(2)
        ])

        let event = await recorder.events()[0]
        XCTAssertEqual(event.traceID, TraceID(rawValue: "existing-trace"))
        XCTAssertEqual(event.parentSpanID, SpanID(rawValue: "parent-span"))
        XCTAssertEqual(event.correlationID, CorrelationID(rawValue: "corr-parent"))
        XCTAssertEqual(event.attributes["feature"], .string("feed"))
        XCTAssertEqual(event.attributes["page"], .integer(2))
    }

    func testStartSpanPrefersDiagnosticContextCorrelationOverParentCorrelation() async {
        let recorder = MemoryObservabilityRecorder()
        let observability = DefaultObservability(
            recorder: recorder,
            clock: FixedClock(date: Date(timeIntervalSince1970: 1)),
            idGenerator: FixedIDGenerator()
        )
        let parent = TraceContext(
            traceID: TraceID(rawValue: "existing-trace"),
            spanID: SpanID(rawValue: "parent-span"),
            correlationID: CorrelationID(rawValue: "corr-parent")
        )
        let diagnosticContext = DiagnosticContext(
            correlationID: CorrelationID(rawValue: "corr-diagnostic"),
            attributes: ["screen": .string("home")]
        )

        let span = await observability.startSpan(
            "feed.child",
            parent: parent,
            attributes: ["page": .integer(2)],
            diagnosticContext: diagnosticContext
        )

        let event = await recorder.events()[0]
        XCTAssertEqual(event.correlationID, CorrelationID(rawValue: "corr-diagnostic"))
        XCTAssertEqual(span.correlationID, CorrelationID(rawValue: "corr-diagnostic"))
        XCTAssertEqual(event.attributes["screen"], .string("home"))
    }

    func testBreadcrumbRecordsDiagnosticContext() async {
        let recorder = MemoryObservabilityRecorder()
        let observability = DefaultObservability(
            recorder: recorder,
            clock: FixedClock(date: Date(timeIntervalSince1970: 42))
        )
        let context = DiagnosticContext(
            correlationID: CorrelationID(rawValue: "corr-42"),
            attributes: ["screen": .string("home")]
        )

        await observability.addBreadcrumb("button.tap", attributes: ["control": .string("retry")], diagnosticContext: context)

        let event = await recorder.events()[0]
        XCTAssertEqual(event.kind, .breadcrumb)
        XCTAssertEqual(event.correlationID, CorrelationID(rawValue: "corr-42"))
        XCTAssertEqual(event.attributes["screen"], .string("home"))
        XCTAssertEqual(event.attributes["control"], .string("retry"))
    }

    func testMeasureRecordsSuccessMeasurement() async throws {
        let recorder = MemoryObservabilityRecorder()
        let observability = DefaultObservability(
            recorder: recorder,
            clock: StepClock([
                Date(timeIntervalSince1970: 100),
                Date(timeIntervalSince1970: 101.25)
            ])
        )

        let value: Int = try await observability.measure("image.decode") {
            42
        }

        XCTAssertEqual(value, 42)
        let event = await recorder.events()[0]
        XCTAssertEqual(event.kind, .measurement)
        XCTAssertEqual(event.status, .ok)
        XCTAssertEqual(event.durationSeconds ?? -1, 1.25, accuracy: 0.001)
    }

    func testMeasureRecordsSanitizedErrorDescriptor() async {
        let recorder = MemoryObservabilityRecorder()
        let observability = DefaultObservability(
            recorder: recorder,
            clock: StepClock([
                Date(timeIntervalSince1970: 100),
                Date(timeIntervalSince1970: 103)
            ])
        )

        do {
            let _: Int = try await observability.measure("network.call") {
                throw TestFailure.offline
            }
            XCTFail("Expected error")
        } catch {
            let event = await recorder.events()[0]
            XCTAssertEqual(event.kind, .measurement)
            XCTAssertEqual(event.status, .failed(ObservabilityErrorDescriptor(category: .network, code: "offline", isRetryable: true)))
            XCTAssertEqual(event.durationSeconds ?? -1, 3, accuracy: 0.001)
        }
    }

    func testMeasureRecordsCancelledStatusForCancellationError() async {
        let recorder = MemoryObservabilityRecorder()
        let observability = DefaultObservability(
            recorder: recorder,
            clock: StepClock([
                Date(timeIntervalSince1970: 100),
                Date(timeIntervalSince1970: 101)
            ])
        )

        do {
            let _: Int = try await observability.measure("network.call") {
                throw CancellationError()
            }
            XCTFail("Expected cancellation")
        } catch is CancellationError {
            let event = await recorder.events()[0]
            XCTAssertEqual(event.kind, .measurement)
            XCTAssertEqual(event.status, .cancelled)
            XCTAssertEqual(event.durationSeconds ?? -1, 1, accuracy: 0.001)
        } catch {
            XCTFail("Expected CancellationError, got \(error)")
        }
    }

    func testMeasureFallbackDoesNotExposeRawErrorText() async {
        struct SensitiveError: Error {
            let token: String
        }
        let recorder = MemoryObservabilityRecorder()
        let observability = DefaultObservability(recorder: recorder)

        do {
            let _: Int = try await observability.measure("sensitive.failure") {
                throw SensitiveError(token: "secret-token")
            }
            XCTFail("Expected error")
        } catch {
            let event = await recorder.events()[0]
            XCTAssertEqual(event.status, .failed(.operationFailed))
        }
    }

    func testRedactorMasksPrivateAndSensitiveKeys() {
        let redactor = ObservabilityRedactor()
        let attributes: ObservabilityAttributes = [
            "token": .string("secret-token"),
            "user": .string("42", privacy: .private),
            "url": .string("https://example.com/feed?token=secret#frag"),
            "count": .integer(10)
        ]

        let redacted = redactor.redact(attributes)

        XCTAssertEqual(redacted["token"], .string("<redacted>", privacy: .private))
        XCTAssertEqual(redacted["user"], .string("<redacted>", privacy: .private))
        XCTAssertEqual(redacted["url"], .string("https://example.com/feed"))
        XCTAssertEqual(redacted["count"], .integer(10))
    }

    func testRedactorRemovesQueryAndFragmentFromRelativeAndSchemeLessURLs() {
        let redactor = ObservabilityRedactor()

        XCTAssertEqual(redactor.redactURLLikeStringIfNeeded("/feed?token=secret#frag"), "/feed")
        XCTAssertEqual(redactor.redactURLLikeStringIfNeeded("feed?token=secret#frag"), "feed")
        XCTAssertEqual(redactor.redactURLLikeStringIfNeeded("//example.com/path?token=secret"), "//example.com/path")
        XCTAssertEqual(redactor.redactURLLikeStringIfNeeded("not a url string"), "not a url string")
    }

    func testRedactingRecorderSanitizesBeforeForwarding() async {
        let memory = MemoryObservabilityRecorder()
        let recorder = RedactingObservabilityRecorder(base: memory)
        await recorder.record(
            ObservabilityEvent(
                kind: .breadcrumb,
                name: "open.url",
                timestamp: Date(timeIntervalSince1970: 1),
                attributes: ["url": .string("https://example.com?a=1")]
            )
        )

        let event = await memory.events()[0]
        XCTAssertEqual(event.attributes["url"], .string("https://example.com"))
    }

    func testMultiplexRecorderForwardsToAllRecorders() async {
        let first = MemoryObservabilityRecorder()
        let second = MemoryObservabilityRecorder()
        let recorder = MultiplexObservabilityRecorder([first, second])
        let event = ObservabilityEvent(kind: .breadcrumb, name: "test", timestamp: Date(timeIntervalSince1970: 1))

        await recorder.record(event)

        let firstEvents = await first.events()
        let secondEvents = await second.events()
        XCTAssertEqual(firstEvents, [event])
        XCTAssertEqual(secondEvents, [event])
    }

    func testTraceContextMergesBaggage() {
        let context = TraceContext(
            traceID: TraceID(rawValue: "trace"),
            spanID: SpanID(rawValue: "span"),
            baggage: ["a": .string("1")]
        )

        let merged = context.mergingBaggage(["b": .string("2")])

        XCTAssertEqual(merged.baggage["a"], .string("1"))
        XCTAssertEqual(merged.baggage["b"], .string("2"))
        XCTAssertEqual(merged.traceID, context.traceID)
    }

    func testDiagnosticContextKeepsCorrelationIDWhenSettingValues() {
        let context = DiagnosticContext(correlationID: CorrelationID(rawValue: "corr"))
        let updated = context.setting(.string("home"), forKey: "screen")

        XCTAssertEqual(updated.correlationID, CorrelationID(rawValue: "corr"))
        XCTAssertEqual(updated.attributes["screen"], .string("home"))
    }

    func testEndingSpanTwiceRecordsOnlyOneSpanEndedEvent() async {
        let recorder = MemoryObservabilityRecorder()
        let clock = StepClock([
            Date(timeIntervalSince1970: 10),
            Date(timeIntervalSince1970: 11),
            Date(timeIntervalSince1970: 12)
        ])
        let observability = DefaultObservability(
            recorder: recorder,
            clock: clock,
            idGenerator: FixedIDGenerator()
        )

        let span = await observability.startSpan("sync.run")
        await span.end(status: .ok, attributes: ["items": .integer(5)])
        await span.end(status: .failed(.operationFailed), attributes: ["items": .integer(6)])

        let endEvents = await recorder.events(kind: .spanEnded)
        XCTAssertEqual(endEvents.count, 1)
        XCTAssertEqual(endEvents[0].status, .ok)
        XCTAssertEqual(endEvents[0].attributes["items"], .integer(5))
    }
}

extension AppObservabilityTests {
    func testObservabilityValueDescriptionDoesNotExposeRawStrings() {
        XCTAssertEqual(String(describing: ObservabilityValue.string("https://example.com?token=secret")), "<string>")
        XCTAssertEqual(String(describing: ObservabilityValue.stringArray(["one", "two"])), "<string_array:2>")
        XCTAssertEqual(ObservabilityValue.string("visible").rawStringForDisplay, "visible")
    }
}
