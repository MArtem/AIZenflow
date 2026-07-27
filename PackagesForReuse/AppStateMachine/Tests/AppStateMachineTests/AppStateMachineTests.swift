import XCTest
@testable import AppStateMachine

final class AppStateMachineTests: XCTestCase {
    func testIdentifiersValidateUnsafeValuesAndRedactDescriptions() throws {
        let state = try StateID("draft")
        XCTAssertEqual(state.rawValue, "draft")
        XCTAssertFalse(state.description.contains("draft"))
        XCTAssertThrowsError(try StateID("../draft"))
        XCTAssertThrowsError(try StateEventID(""))
    }

    func testDefinitionRejectsDuplicateTransitionsAndUnknownStates() throws {
        let draft = try StateID("draft")
        let published = try StateID("published")
        let publish = try StateEventID("publish")
        let machineID = try StateMachineID("article")
        let transition = StateTransition(from: draft, event: publish, to: published)

        XCTAssertThrowsError(
            try StateMachineDefinition(
                id: machineID,
                states: [draft, published],
                initialState: draft,
                transitions: [transition, transition]
            )
        )

        let archived = try StateID("archived")
        XCTAssertThrowsError(
            try StateMachineDefinition(
                id: machineID,
                states: [draft, published],
                initialState: draft,
                transitions: [StateTransition(from: published, event: publish, to: archived)]
            )
        )
    }

    func testAcceptedTransitionPersistsSnapshot() async throws {
        let fixture = try makeFixture()
        let store = InMemoryStateMachineStore()
        let clock = ManualStateMachineClock()
        let machine = AppStateMachine(definition: fixture.definition, store: store, clock: clock)

        await clock.advance(milliseconds: 10)
        let result = try await machine.send(StateMachineEvent(id: fixture.publish))

        XCTAssertTrue(result.isAccepted)
        XCTAssertEqual(result.snapshot.state, fixture.published)
        XCTAssertEqual(result.snapshot.revision, 1)
        let persisted = try await machine.currentSnapshot()
        XCTAssertEqual(persisted.state, fixture.published)
    }

    func testGuardCanRejectTransitionWithoutChangingState() async throws {
        let fixture = try makeGuardedFixture()
        let guardID = try StateGuardID("canPublish")
        let machine = AppStateMachine(
            definition: fixture.definition,
            clock: ManualStateMachineClock(),
            guards: [StaticGuard(id: guardID, allowed: false)]
        )

        let result = try await machine.send(StateMachineEvent(id: fixture.publish))

        XCTAssertFalse(result.isAccepted)
        XCTAssertEqual(result, .rejected(.guardRejected, result.snapshot))
        XCTAssertEqual(result.snapshot.state, fixture.draft)
        XCTAssertEqual(result.snapshot.revision, 0)
    }

    func testActionExecutesBeforeCommit() async throws {
        let fixture = try makeActionFixture()
        let actionID = try StateActionID("notify")
        let recorder = ActionRecorder()
        let machine = AppStateMachine(
            definition: fixture.definition,
            clock: ManualStateMachineClock(),
            actions: [RecordingAction(id: actionID, recorder: recorder)]
        )

        let result = try await machine.send(StateMachineEvent(id: fixture.publish))
        let actionCount = await recorder.count()

        XCTAssertTrue(result.isAccepted)
        XCTAssertEqual(actionCount, 1)
        XCTAssertEqual(result.snapshot.state, fixture.published)
    }

    func testFailingActionRejectsWithoutCommit() async throws {
        let fixture = try makeActionFixture()
        let actionID = try StateActionID("notify")
        let machine = AppStateMachine(
            definition: fixture.definition,
            clock: ManualStateMachineClock(),
            actions: [FailingAction(id: actionID)]
        )

        let result = try await machine.send(StateMachineEvent(id: fixture.publish))
        let current = try await machine.currentSnapshot()

        XCTAssertFalse(result.isAccepted)
        XCTAssertEqual(result.snapshot.state, fixture.draft)
        XCTAssertEqual(current.state, fixture.draft)
        XCTAssertEqual(current.revision, 0)
    }

    func testStoreFailuresPropagateToHostBoundary() async throws {
        let fixture = try makeFixture()
        let machine = AppStateMachine(definition: fixture.definition, store: FailingStateMachineStore())

        do {
            _ = try await machine.send(StateMachineEvent(id: fixture.publish))
            XCTFail("Expected store failure to propagate")
        } catch let error as TestStateMachineStoreFailure {
            XCTAssertEqual(error, .unavailable)
        }
    }

    func testConcurrentSendsAreSerializedAcrossAwaitingActions() async throws {
        let idle = try StateID("idle")
        let middle = try StateID("middle")
        let done = try StateID("done")
        let advance = try StateEventID("advance")
        let actionID = try StateActionID("slowAction")
        let definition = try StateMachineDefinition(
            id: try StateMachineID("serial"),
            states: [idle, middle, done],
            initialState: idle,
            transitions: [
                StateTransition(from: idle, event: advance, to: middle, actionID: actionID),
                StateTransition(from: middle, event: advance, to: done)
            ]
        )
        let gate = ActionGate()
        let machine = AppStateMachine(
            definition: definition,
            actions: [BlockingAction(id: actionID, gate: gate)]
        )

        async let first = machine.send(StateMachineEvent(id: advance))
        await gate.waitUntilStarted()
        async let second = machine.send(StateMachineEvent(id: advance))
        await gate.release()

        let firstResult = try await first
        let secondResult = try await second
        let finalSnapshot = try await machine.currentSnapshot()

        XCTAssertTrue(firstResult.isAccepted)
        XCTAssertTrue(secondResult.isAccepted)
        XCTAssertEqual(finalSnapshot.state, done)
        XCTAssertEqual(finalSnapshot.revision, 2)
    }

    func testRevisionSaturatesAtMaximumValue() throws {
        let fixture = try makeFixture()
        let snapshot = StateMachineSnapshot(
            machineID: fixture.definition.id,
            state: fixture.draft,
            revision: UInt64.max,
            updatedAt: StateMachineInstant(millisecondsSinceEpoch: 0)
        )
        let transition = StateTransition(from: fixture.draft, event: fixture.publish, to: fixture.published)
        let updated = snapshot.applying(
            transition: transition,
            event: StateMachineEvent(id: fixture.publish),
            at: StateMachineInstant(millisecondsSinceEpoch: 1)
        )

        XCTAssertEqual(updated.revision, UInt64.max)
    }

    func testMetadataIsValidatedAndRedacted() throws {
        let metadata = try StateMetadata(["safe_key": "value-that-must-not-leak"])
        XCTAssertFalse(metadata.description.contains("value-that-must-not-leak"))
        XCTAssertThrowsError(try StateMetadata(["unsafe key": "value"]))
        let largeValue = String(repeating: "a", count: StateMetadata.maximumEncodedBytes + 1)
        XCTAssertThrowsError(try StateMetadata(["large": largeValue]))
    }

    func testCodableDecodingKeepsIdentifierValidation() throws {
        let validID = try JSONDecoder().decode(StateID.self, from: Data(#""draft""#.utf8))
        XCTAssertEqual(validID.rawValue, "draft")
        XCTAssertThrowsError(try JSONDecoder().decode(StateID.self, from: Data(#""../draft""#.utf8)))
    }

    private func makeFixture() throws -> Fixture {
        let draft = try StateID("draft")
        let published = try StateID("published")
        let publish = try StateEventID("publish")
        let definition = try StateMachineDefinition(
            id: try StateMachineID("article"),
            states: [draft, published],
            initialState: draft,
            transitions: [StateTransition(from: draft, event: publish, to: published)]
        )
        return Fixture(definition: definition, draft: draft, published: published, publish: publish)
    }

    private func makeGuardedFixture() throws -> Fixture {
        let draft = try StateID("draft")
        let published = try StateID("published")
        let publish = try StateEventID("publish")
        let definition = try StateMachineDefinition(
            id: try StateMachineID("article"),
            states: [draft, published],
            initialState: draft,
            transitions: [
                StateTransition(
                    from: draft,
                    event: publish,
                    to: published,
                    guardID: try StateGuardID("canPublish")
                )
            ]
        )
        return Fixture(definition: definition, draft: draft, published: published, publish: publish)
    }

    private func makeActionFixture() throws -> Fixture {
        let draft = try StateID("draft")
        let published = try StateID("published")
        let publish = try StateEventID("publish")
        let definition = try StateMachineDefinition(
            id: try StateMachineID("article"),
            states: [draft, published],
            initialState: draft,
            transitions: [
                StateTransition(
                    from: draft,
                    event: publish,
                    to: published,
                    actionID: try StateActionID("notify")
                )
            ]
        )
        return Fixture(definition: definition, draft: draft, published: published, publish: publish)
    }
}

private struct Fixture {
    let definition: StateMachineDefinition
    let draft: StateID
    let published: StateID
    let publish: StateEventID
}

private struct StaticGuard: StateTransitionGuard {
    let id: StateGuardID
    let allowed: Bool

    func allowsTransition(_ evaluation: StateTransitionEvaluation) async -> Bool {
        allowed
    }
}

private actor ActionRecorder {
    private var value = 0

    func increment() {
        value += 1
    }

    func count() -> Int {
        value
    }
}

private struct RecordingAction: StateTransitionAction {
    let id: StateActionID
    let recorder: ActionRecorder

    func executeTransition(_ evaluation: StateTransitionEvaluation) async throws {
        await recorder.increment()
    }
}

private struct FailingAction: StateTransitionAction {
    let id: StateActionID

    func executeTransition(_ evaluation: StateTransitionEvaluation) async throws {
        throw StateMachineFailure.actionFailed
    }
}


private enum TestStateMachineStoreFailure: Error, Equatable {
    case unavailable
}

private actor FailingStateMachineStore: StateMachineStore {
    func loadSnapshot(for machineID: StateMachineID) async throws -> StateMachineSnapshot? {
        throw TestStateMachineStoreFailure.unavailable
    }

    func saveSnapshot(_ snapshot: StateMachineSnapshot) async throws {
        throw TestStateMachineStoreFailure.unavailable
    }

    func resetSnapshot(for machineID: StateMachineID) async throws {
        throw TestStateMachineStoreFailure.unavailable
    }
}

private actor ActionGate {
    private var startedContinuation: CheckedContinuation<Void, Never>?
    private var releaseContinuation: CheckedContinuation<Void, Never>?
    private var started = false
    private var released = false

    func markStartedAndWaitForRelease() async {
        started = true
        startedContinuation?.resume()
        startedContinuation = nil
        if released {
            return
        }
        await withCheckedContinuation { continuation in
            releaseContinuation = continuation
        }
    }

    func waitUntilStarted() async {
        if started {
            return
        }
        await withCheckedContinuation { continuation in
            startedContinuation = continuation
        }
    }

    func release() {
        released = true
        releaseContinuation?.resume()
        releaseContinuation = nil
    }
}

private struct BlockingAction: StateTransitionAction {
    let id: StateActionID
    let gate: ActionGate

    func executeTransition(_ evaluation: StateTransitionEvaluation) async throws {
        await gate.markStartedAndWaitForRelease()
    }
}
