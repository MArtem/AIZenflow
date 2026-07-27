import Foundation
import XCTest
@testable import AppTaskQueue

final class AppTaskQueueTests: XCTestCase {
    func testIdentifiersValidateUnsafeInput() throws {
        XCTAssertThrowsError(try AppTaskID("../escape"))
        XCTAssertThrowsError(try AppTaskKind(""))

        let id = try AppTaskID("task-001")
        XCTAssertEqual(id.storageKey, "task-001")
        XCTAssertEqual(id.description, "AppTaskID(redacted)")
    }

    func testPayloadRejectsOversizedData() throws {
        let data = Data(repeating: 1, count: 4)
        XCTAssertThrowsError(try AppTaskPayload(data: data, maximumBytes: 3))
        XCTAssertThrowsError(try AppTaskPayload(data: Data(), maximumBytes: 0))
        XCTAssertThrowsError(try AppTaskPayload(data: data, mediaType: " application/json", maximumBytes: 4))
        XCTAssertThrowsError(try AppTaskPayload(data: data, mediaType: "application /json", maximumBytes: 4))

        let payload = try AppTaskPayload(data: data, mediaType: "application/octet-stream", maximumBytes: 4)
        XCTAssertEqual(payload.byteCount, 4)
        XCTAssertFalse(payload.description.contains("application/octet-stream"))
    }

    func testRetryPolicyRejectsUnsafeBounds() throws {
        XCTAssertThrowsError(
            try AppTaskRetryPolicy(
                maximumAttempts: AppTaskRetryPolicy.maximumSupportedAttempts + 1,
                initialDelay: 1,
                multiplier: 2,
                maximumDelay: 60
            ).validated()
        )
        XCTAssertThrowsError(
            try AppTaskRetryPolicy(
                maximumAttempts: 3,
                initialDelay: 60,
                multiplier: 2,
                maximumDelay: 1
            ).validated()
        )

        let policy = try AppTaskRetryPolicy(
            maximumAttempts: AppTaskRetryPolicy.maximumSupportedAttempts,
            initialDelay: 1,
            multiplier: .greatestFiniteMagnitude,
            maximumDelay: 60
        ).validated()
        XCTAssertEqual(policy.delay(afterAttemptCount: 3), 60)
    }

    func testQueueReservesHighestPriorityDueTaskFirst() async throws {
        let clock = FixedAppTaskQueueClock(Date(timeIntervalSince1970: 100))
        let store = try InMemoryAppTaskQueueStore()
        let queue = AppTaskQueueService(store: store, clock: clock)

        _ = try await queue.enqueue(makeRequest(id: "low", priority: .low))
        _ = try await queue.enqueue(makeRequest(id: "high", priority: .high))

        let reserved = try await queue.reserveNext()
        XCTAssertEqual(reserved?.id.storageKey, "high")
        XCTAssertEqual(reserved?.state, .reserved)
        XCTAssertEqual(reserved?.attemptCount, 1)
    }

    func testQueueDoesNotReserveDeferredTaskEarly() async throws {
        let now = Date(timeIntervalSince1970: 100)
        let clock = FixedAppTaskQueueClock(now)
        let store = try InMemoryAppTaskQueueStore()
        let queue = AppTaskQueueService(store: store, clock: clock)
        let deferred = AppTaskSchedule(notBefore: now.addingTimeInterval(60))

        _ = try await queue.enqueue(makeRequest(id: "deferred", schedule: deferred))

        let reserved = try await queue.reserveNext()
        XCTAssertNil(reserved)
    }

    func testRunnerMarksSuccessfulExecution() async throws {
        let clock = FixedAppTaskQueueClock(Date(timeIntervalSince1970: 100))
        let store = try InMemoryAppTaskQueueStore()
        let queue = AppTaskQueueService(store: store, clock: clock)
        _ = try await queue.enqueue(makeRequest(id: "success"))
        let runner = AppTaskQueueRunner(queue: queue, executor: StaticExecutor(decision: .succeeded))

        let report = try await runner.runOne()
        let task = try await queue.task(id: AppTaskID("success"))

        XCTAssertEqual(report.outcome, .succeeded)
        XCTAssertEqual(task?.state, .succeeded)
    }

    func testQueuedTaskCannotBeCompletedBeforeReservation() async throws {
        let clock = FixedAppTaskQueueClock(Date(timeIntervalSince1970: 100))
        let store = try InMemoryAppTaskQueueStore()
        let queue = AppTaskQueueService(store: store, clock: clock)
        _ = try await queue.enqueue(makeRequest(id: "queued"))

        await XCTAssertThrowsErrorAsync {
            _ = try await queue.complete(id: AppTaskID("queued"))
        }
        await XCTAssertThrowsErrorAsync {
            _ = try await queue.fail(id: AppTaskID("queued"))
        }

        let task = try await queue.task(id: AppTaskID("queued"))
        XCTAssertEqual(task?.state, .queued)
    }

    func testRunnerSchedulesRetryWhenAttemptsRemain() async throws {
        let clockDate = Date(timeIntervalSince1970: 100)
        let clock = FixedAppTaskQueueClock(clockDate)
        let store = try InMemoryAppTaskQueueStore()
        let queue = AppTaskQueueService(store: store, clock: clock)
        let retry = AppTaskRetryPolicy(maximumAttempts: 3, initialDelay: 10, multiplier: 2, maximumDelay: 60)
        _ = try await queue.enqueue(makeRequest(id: "retry", retryPolicy: retry))
        let runner = AppTaskQueueRunner(queue: queue, executor: StaticExecutor(decision: .retry))

        let report = try await runner.runOne()
        let task = try await queue.task(id: AppTaskID("retry"))

        XCTAssertEqual(report.outcome, .scheduledRetry)
        XCTAssertEqual(task?.state, .queued)
        XCTAssertEqual(task?.schedule.notBefore, clockDate.addingTimeInterval(10))
    }

    func testRunnerFailsWhenRetryAttemptsAreExhausted() async throws {
        let clock = FixedAppTaskQueueClock(Date(timeIntervalSince1970: 100))
        let store = try InMemoryAppTaskQueueStore()
        let queue = AppTaskQueueService(store: store, clock: clock)
        let retry = AppTaskRetryPolicy.noRetry
        _ = try await queue.enqueue(makeRequest(id: "exhausted", retryPolicy: retry))
        let runner = AppTaskQueueRunner(queue: queue, executor: StaticExecutor(decision: .retry))

        let report = try await runner.runOne()
        let task = try await queue.task(id: AppTaskID("exhausted"))

        XCTAssertEqual(report.outcome, .failed)
        XCTAssertEqual(task?.state, .failed)
    }

    private func makeRequest(
        id: String,
        priority: AppTaskPriority = .normal,
        schedule: AppTaskSchedule = .immediate,
        retryPolicy: AppTaskRetryPolicy = .standard
    ) throws -> AppTaskEnqueueRequest {
        try AppTaskEnqueueRequest(
            id: AppTaskID(id),
            kind: AppTaskKind("sync.example"),
            payload: AppTaskPayload(data: Data([1, 2, 3])),
            priority: priority,
            schedule: schedule,
            retryPolicy: retryPolicy
        )
    }
}

private func XCTAssertThrowsErrorAsync(
    _ expression: () async throws -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        try await expression()
        XCTFail("Expected async expression to throw", file: file, line: line)
    } catch {
        // Expected path.
    }
}

private struct StaticExecutor: AppTaskExecutor {
    let decision: AppTaskExecutionDecision

    func execute(_ task: AppQueuedTask, context: AppTaskExecutionContext) async -> AppTaskExecutionDecision {
        decision
    }
}
