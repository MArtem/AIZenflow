import XCTest
@testable import AppLifecycle

final class AppLifecycleTests: XCTestCase {
    func testInitialSnapshotUsesInitialPhase() async {
        let date = Date(timeIntervalSince1970: 100)
        let manager = DefaultAppLifecycleManager(
            clock: StaticAppLifecycleClock(date: date),
            initialPhase: .inactive
        )

        let snapshot = await manager.snapshot()

        XCTAssertEqual(snapshot.phase, .inactive)
        XCTAssertEqual(snapshot.launchStartedAt, date)
        XCTAssertEqual(snapshot.foregroundEntryCount, 0)
        XCTAssertEqual(snapshot.backgroundEntryCount, 0)
    }

    func testStartLaunchClassifiesFirstLaunch() async throws {
        let manager = DefaultAppLifecycleManager(
            clock: StaticAppLifecycleClock(date: Date(timeIntervalSince1970: 200))
        )

        let snapshot = try await manager.startLaunch(
            buildIdentity: AppLifecycleBuildIdentity(version: "1.0", build: "1")
        )

        XCTAssertEqual(snapshot.launchClassification, .firstLaunch)
        XCTAssertEqual(snapshot.lastEvent?.kind, .launchStarted)
    }

    func testStartLaunchClassifiesSameBuildRelaunch() async throws {
        let identity = AppLifecycleBuildIdentity(version: "1.0", build: "1")
        let store = InMemoryAppLifecycleStateStore(
            initialState: AppLifecyclePersistedState(
                launchCount: 1,
                lastKnownBuildIdentity: identity
            )
        )
        let manager = DefaultAppLifecycleManager(stateStore: store)

        let snapshot = try await manager.startLaunch(buildIdentity: identity)

        XCTAssertEqual(snapshot.launchClassification, .sameBuildRelaunch)
    }

    func testStartLaunchClassifiesUpdatedBuild() async throws {
        let previous = AppLifecycleBuildIdentity(version: "1.0", build: "1")
        let current = AppLifecycleBuildIdentity(version: "1.1", build: "2")
        let store = InMemoryAppLifecycleStateStore(
            initialState: AppLifecyclePersistedState(
                launchCount: 3,
                lastKnownBuildIdentity: previous
            )
        )
        let manager = DefaultAppLifecycleManager(stateStore: store)

        let snapshot = try await manager.startLaunch(buildIdentity: current)

        XCTAssertEqual(snapshot.launchClassification, .updated(previous: previous))
    }

    func testDidBecomeActiveChangesPhaseAndIncrementsForegroundCount() async throws {
        let manager = DefaultAppLifecycleManager(initialPhase: .inactive)

        let snapshot = try await manager.record(.didBecomeActive)

        XCTAssertEqual(snapshot.phase, .active)
        XCTAssertEqual(snapshot.foregroundEntryCount, 1)
        XCTAssertEqual(snapshot.backgroundEntryCount, 0)
    }

    func testRepeatedActiveDoesNotIncrementForegroundCountAgain() async throws {
        let manager = DefaultAppLifecycleManager(initialPhase: .inactive)

        _ = try await manager.record(.didBecomeActive)
        let snapshot = try await manager.record(.didBecomeActive)

        XCTAssertEqual(snapshot.phase, .active)
        XCTAssertEqual(snapshot.foregroundEntryCount, 1)
    }

    func testDidEnterBackgroundChangesPhaseAndIncrementsBackgroundCount() async throws {
        let manager = DefaultAppLifecycleManager(initialPhase: .active)

        let snapshot = try await manager.record(.didEnterBackground)

        XCTAssertEqual(snapshot.phase, .background)
        XCTAssertEqual(snapshot.backgroundEntryCount, 1)
    }

    func testSetPhaseUsesProvidedReason() async throws {
        let manager = DefaultAppLifecycleManager(initialPhase: .active)

        let snapshot = try await manager.setPhase(.terminated, reason: .willTerminate)

        XCTAssertEqual(snapshot.phase, .terminated)
        XCTAssertEqual(snapshot.lastEvent?.kind, .willTerminate)
    }

    func testEventStreamReceivesEvents() async throws {
        let manager = DefaultAppLifecycleManager(initialPhase: .inactive)
        let stream = await manager.eventStream()
        let expectation = expectation(description: "event delivered")

        let task = Task {
            var iterator = stream.makeAsyncIterator()
            let event = await iterator.next()
            XCTAssertEqual(event?.kind, .didBecomeActive)
            expectation.fulfill()
        }

        _ = try await manager.record(.didBecomeActive)
        await fulfillment(of: [expectation], timeout: 2)
        task.cancel()
    }

    func testPrivateAttributeIsRedacted() async throws {
        let manager = DefaultAppLifecycleManager()

        let snapshot = try await manager.record(
            .custom,
            attributes: [
                "note": .privateString("private value")
            ]
        )

        XCTAssertEqual(snapshot.lastEvent?.attributes["note"]?.value, .string("<private>"))
    }

    func testSensitiveKeyIsRedactedEvenWhenMarkedPublic() async throws {
        let manager = DefaultAppLifecycleManager()

        let snapshot = try await manager.record(
            .custom,
            attributes: [
                "access_token": .publicString("secret-token")
            ]
        )

        XCTAssertEqual(snapshot.lastEvent?.attributes["access_token"]?.value, .string("<sensitive>"))
    }

    func testAttributeValueDescriptionDoesNotExposeRawString() {
        let value = AppLifecycleAttributeValue.string("private text")

        XCTAssertEqual(value.description, "<redacted-string>")
    }

    func testDiagnosticsAreSummaryOriented() async throws {
        let manager = DefaultAppLifecycleManager(initialPhase: .active)
        _ = try await manager.record(.didEnterBackground)

        let diagnostics = await manager.diagnostics()

        XCTAssertEqual(diagnostics.phase, .background)
        XCTAssertEqual(diagnostics.backgroundEntryCount, 1)
        XCTAssertTrue(diagnostics.hasLastEvent)
    }

    func testPersistedStateCanBeReset() async throws {
        let identity = AppLifecycleBuildIdentity(version: "1.0", build: "1")
        let store = InMemoryAppLifecycleStateStore()
        let manager = DefaultAppLifecycleManager(stateStore: store)

        _ = try await manager.startLaunch(buildIdentity: identity)
        try await manager.resetPersistedState()
        let persisted = try await store.loadState()

        XCTAssertNil(persisted)
    }
}
