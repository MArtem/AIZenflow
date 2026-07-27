import XCTest
@testable import AppBackgroundTasks

final actor AttemptRecorder {
    private var values: [Int] = []

    func append(_ value: Int) {
        values.append(value)
    }

    func snapshot() -> [Int] {
        values
    }
}

final class AppBackgroundTasksTests: XCTestCase {
    func testIdentifierValidationRejectsEmptyValue() throws {
        XCTAssertThrowsError(try BackgroundTaskIdentifier(validating: "   ")) { error in
            XCTAssertEqual(error as? BackgroundTaskError, .invalidIdentifier)
        }
    }

    func testIdentifierDescriptionIsRedacted() {
        let identifier = BackgroundTaskIdentifier(rawValue: "com.example.refresh.auth-token")
        XCTAssertFalse(identifier.description.contains(identifier.rawValue))
        XCTAssertTrue(identifier.description.contains("<redacted>"))
    }

    func testTaskKindDiagnosticCodesAreStable() {
        XCTAssertEqual(BackgroundTaskKind.appRefresh.diagnosticCode, "app_refresh")
        XCTAssertEqual(BackgroundTaskKind.processing.diagnosticCode, "processing")
        XCTAssertEqual(BackgroundTaskKind.custom("secret-feature").diagnosticCode, "custom")
    }

    func testSchedulerRegistersTask() async throws {
        let scheduler = ManualBackgroundTaskScheduler(clock: StaticBackgroundTaskClock(date: Date(timeIntervalSince1970: 10)))
        let registration = BackgroundTaskRegistration(identifier: "refresh", kind: .appRefresh)

        try await scheduler.register(registration)

        let registrations = await scheduler.registrations()
        XCTAssertEqual(registrations, [registration])
        let events = await scheduler.events()
        XCTAssertEqual(events.map(\.kind), [.registered])
    }

    func testSchedulerRejectsDuplicateRegistration() async throws {
        let scheduler = ManualBackgroundTaskScheduler()
        let registration = BackgroundTaskRegistration(identifier: "refresh", kind: .appRefresh)
        try await scheduler.register(registration)

        do {
            try await scheduler.register(registration)
            XCTFail("Expected duplicate registration to fail")
        } catch {
            XCTAssertEqual(error as? BackgroundTaskError, .alreadyRegistered)
        }
    }

    func testScheduleRequiresRegistration() async throws {
        let scheduler = ManualBackgroundTaskScheduler()
        let request = BackgroundTaskRequest(identifier: "refresh", kind: .appRefresh)

        do {
            try await scheduler.schedule(request)
            XCTFail("Expected scheduling to fail")
        } catch {
            XCTAssertEqual(error as? BackgroundTaskError, .notRegistered)
        }
    }

    func testSchedulingStoresPendingRequest() async throws {
        let scheduler = ManualBackgroundTaskScheduler()
        let registration = BackgroundTaskRegistration(identifier: "refresh", kind: .appRefresh)
        let request = BackgroundTaskRequest(identifier: "refresh", kind: .appRefresh, priority: .high)

        try await scheduler.register(registration)
        try await scheduler.schedule(request)

        let pendingRequests = await scheduler.pendingRequests()
        let events = await scheduler.events()
        XCTAssertEqual(pendingRequests, [request])
        XCTAssertEqual(events.map(\.kind), [.registered, .scheduled])
    }

    func testSchedulingRejectsKindMismatch() async throws {
        let scheduler = ManualBackgroundTaskScheduler()
        try await scheduler.register(BackgroundTaskRegistration(identifier: "task", kind: .appRefresh))

        do {
            try await scheduler.schedule(BackgroundTaskRequest(identifier: "task", kind: .processing))
            XCTFail("Expected kind mismatch")
        } catch {
            XCTAssertEqual(error as? BackgroundTaskError, .schedulingRejected("kind_mismatch"))
        }
    }

    func testCancelRemovesPendingRequest() async throws {
        let scheduler = ManualBackgroundTaskScheduler()
        try await scheduler.register(BackgroundTaskRegistration(identifier: "refresh", kind: .appRefresh))
        try await scheduler.schedule(BackgroundTaskRequest(identifier: "refresh", kind: .appRefresh))

        await scheduler.cancel(identifier: "refresh")

        let pendingRequests = await scheduler.pendingRequests()
        let events = await scheduler.events()
        XCTAssertTrue(pendingRequests.isEmpty)
        XCTAssertEqual(events.last?.kind, .cancelled)
    }

    func testCancelAllRemovesAllPendingRequests() async throws {
        let scheduler = ManualBackgroundTaskScheduler()
        try await scheduler.register(BackgroundTaskRegistration(identifier: "one", kind: .appRefresh))
        try await scheduler.register(BackgroundTaskRegistration(identifier: "two", kind: .processing))
        try await scheduler.schedule(BackgroundTaskRequest(identifier: "one", kind: .appRefresh))
        try await scheduler.schedule(BackgroundTaskRequest(identifier: "two", kind: .processing))

        await scheduler.cancelAll()

        let pendingRequests = await scheduler.pendingRequests()
        let events = await scheduler.events()
        XCTAssertTrue(pendingRequests.isEmpty)
        XCTAssertEqual(events.filter { $0.kind == .cancelled }.count, 2)
    }

    func testDiagnosticsDoNotExposeRawIdentifiers() async throws {
        let scheduler = ManualBackgroundTaskScheduler()
        try await scheduler.register(BackgroundTaskRegistration(identifier: "com.secret.refresh", kind: .appRefresh))
        try await scheduler.schedule(BackgroundTaskRequest(identifier: "com.secret.refresh", kind: .appRefresh))

        let diagnostics = await scheduler.diagnostics()

        XCTAssertEqual(diagnostics.registeredCount, 1)
        XCTAssertEqual(diagnostics.pendingCount, 1)
        XCTAssertEqual(diagnostics.registeredKinds, ["app_refresh"])
        XCTAssertFalse(String(describing: diagnostics).contains("com.secret.refresh"))
    }

    func testManagerRunsPendingTaskAndRecordsCompletion() async throws {
        let scheduler = ManualBackgroundTaskScheduler(clock: StaticBackgroundTaskClock(date: Date(timeIntervalSince1970: 20)))
        let manager = DefaultBackgroundTaskManager(
            scheduler: scheduler,
            clock: StaticBackgroundTaskClock(date: Date(timeIntervalSince1970: 30))
        )
        try await manager.register(
            BackgroundTaskRegistration(identifier: "refresh", kind: .appRefresh),
            handler: AnyBackgroundTaskHandler { context in
                XCTAssertEqual(context.identifier.rawValue, "refresh")
                XCTAssertEqual(context.kind, .appRefresh)
                XCTAssertEqual(context.attempt, 1)
                return .success
            }
        )
        try await manager.schedule(BackgroundTaskRequest(identifier: "refresh", kind: .appRefresh))

        let result = try await manager.runPending(identifier: "refresh")

        XCTAssertEqual(result, .success)
        let pendingRequests = await manager.pendingRequests()
        let events = await manager.events()
        XCTAssertTrue(pendingRequests.isEmpty)
        XCTAssertEqual(events.map(\.kind), [.registered, .scheduled, .started, .completed])
    }

    func testManagerIncrementsAttempts() async throws {
        let manager = DefaultBackgroundTaskManager()
        let recorder = AttemptRecorder()
        try await manager.register(
            BackgroundTaskRegistration(identifier: "refresh", kind: .appRefresh),
            handler: AnyBackgroundTaskHandler { context in
                await recorder.append(context.attempt)
                return .noData
            }
        )

        try await manager.schedule(BackgroundTaskRequest(identifier: "refresh", kind: .appRefresh))
        _ = try await manager.runPending(identifier: "refresh")
        try await manager.schedule(BackgroundTaskRequest(identifier: "refresh", kind: .appRefresh))
        _ = try await manager.runPending(identifier: "refresh")

        let observedAttempts = await recorder.snapshot()
        XCTAssertEqual(observedAttempts, [1, 2])
    }


    func testFailureCodeSanitizesRawDiagnosticValue() {
        let code = BackgroundTaskFailureCode(rawValue: "  Auth Token: SECRET@example.com/very/long/path/that/should/not/be_preserved_as_raw_text  ")

        XCTAssertFalse(code.rawValue.contains("SECRET"))
        XCTAssertFalse(code.rawValue.contains("@"))
        XCTAssertFalse(code.rawValue.contains("/"))
        XCTAssertLessThanOrEqual(code.rawValue.count, 64)
    }


    func testRunPendingWithoutHandlerDoesNotDropPendingRequest() async throws {
        let scheduler = ManualBackgroundTaskScheduler()
        try await scheduler.register(BackgroundTaskRegistration(identifier: "refresh", kind: .appRefresh))
        try await scheduler.schedule(BackgroundTaskRequest(identifier: "refresh", kind: .appRefresh))
        let manager = DefaultBackgroundTaskManager(scheduler: scheduler)

        do {
            _ = try await manager.runPending(identifier: "refresh")
            XCTFail("Expected missing handler to fail")
        } catch {
            XCTAssertEqual(error as? BackgroundTaskError, .executionUnavailable)
        }

        let pendingRequests = await scheduler.pendingRequests()
        XCTAssertEqual(pendingRequests.map(\.identifier), ["refresh"])
    }

    func testBackgroundTaskResultSystemSuccessMapping() {
        XCTAssertTrue(BackgroundTaskResult.success.isSuccessfulForSystemScheduler)
        XCTAssertTrue(BackgroundTaskResult.noData.isSuccessfulForSystemScheduler)
        XCTAssertFalse(BackgroundTaskResult.failed(BackgroundTaskFailure(code: "network", isRetryable: true)).isSuccessfulForSystemScheduler)
        XCTAssertFalse(BackgroundTaskResult.cancelled.isSuccessfulForSystemScheduler)
        XCTAssertFalse(BackgroundTaskResult.expired.isSuccessfulForSystemScheduler)
    }
}
