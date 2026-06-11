import XCTest
@testable import AppConnectivity

final class AppConnectivityTests: XCTestCase {
    func testOnlineSnapshotIsUsable() {
        let snapshot = ConnectivitySnapshot.online(interfaces: [.wifi])
        XCTAssertTrue(snapshot.isOnline)
        XCTAssertTrue(snapshot.isAllowed(by: .permissive))
        XCTAssertEqual(snapshot.primaryInterface, .wifi)
    }

    func testOfflineSnapshotIsNotUsable() {
        let snapshot = ConnectivitySnapshot.offline()
        XCTAssertFalse(snapshot.isOnline)
        XCTAssertFalse(snapshot.isAllowed(by: .permissive))
    }

    func testUnknownSnapshotIsNotUsable() {
        let snapshot = ConnectivitySnapshot.unknown()
        XCTAssertFalse(snapshot.isOnline)
        XCTAssertFalse(snapshot.isAllowed(by: .permissive))
        XCTAssertEqual(snapshot.primaryInterface, .unknown)
    }

    func testConservativePolicyRejectsExpensiveConnections() {
        let snapshot = ConnectivitySnapshot.online(interfaces: [.cellular], isExpensive: true)
        XCTAssertTrue(snapshot.isAllowed(by: .permissive))
        XCTAssertFalse(snapshot.isAllowed(by: .conservative))
    }

    func testConservativePolicyRejectsConstrainedConnections() {
        let snapshot = ConnectivitySnapshot.online(interfaces: [.wifi], isConstrained: true)
        XCTAssertTrue(snapshot.isAllowed(by: .permissive))
        XCTAssertFalse(snapshot.isAllowed(by: .conservative))
    }

    func testCustomPolicyCanAllowExpensiveButRejectConstrained() {
        let policy = ConnectivityCostPolicy(
            allowsExpensiveConnections: true,
            allowsConstrainedConnections: false
        )
        XCTAssertTrue(ConnectivitySnapshot.online(isExpensive: true).isAllowed(by: policy))
        XCTAssertFalse(ConnectivitySnapshot.online(isConstrained: true).isAllowed(by: policy))
    }

    func testManualMonitorReturnsInitialSnapshot() async {
        let monitor = ManualConnectivityMonitor(initialSnapshot: .offline())
        let snapshot = await monitor.currentSnapshot()
        XCTAssertEqual(snapshot.status, .offline)
    }

    func testManualMonitorUpdatesCurrentSnapshot() async {
        let monitor = ManualConnectivityMonitor(initialSnapshot: .offline())
        await monitor.update(.online(interfaces: [.wifi]))
        let snapshot = await monitor.currentSnapshot()
        XCTAssertEqual(snapshot.status, .online)
        XCTAssertEqual(snapshot.interfaces, [.wifi])
    }

    func testManualMonitorStreamEmitsInitialSnapshotAndUpdates() async {
        let monitor = ManualConnectivityMonitor(initialSnapshot: .offline())
        let stream = await monitor.snapshots()
        var iterator = stream.makeAsyncIterator()

        let first = await iterator.next()
        XCTAssertEqual(first?.status, .offline)

        await monitor.update(.online(interfaces: [.wifi]))
        let second = await iterator.next()
        XCTAssertEqual(second?.status, .online)
        XCTAssertEqual(second?.interfaces, [.wifi])
    }

    func testManualMonitorStopFinishesStream() async {
        let monitor = ManualConnectivityMonitor(initialSnapshot: .offline())
        let stream = await monitor.snapshots()
        var iterator = stream.makeAsyncIterator()

        _ = await iterator.next()
        await monitor.stop()
        let next = await iterator.next()
        XCTAssertNil(next)
    }

    func testStaticMonitorEmitsSingleSnapshot() async {
        let monitor = StaticConnectivityMonitor(snapshot: .online(interfaces: [.wifi]))
        let stream = await monitor.snapshots()
        var iterator = stream.makeAsyncIterator()

        let first = await iterator.next()
        XCTAssertEqual(first?.status, .online)
        let second = await iterator.next()
        XCTAssertNil(second)
    }

    func testConnectivityChangeDetectsBecameOnline() {
        let change = ConnectivityChange(previous: .offline(), current: .online())
        XCTAssertTrue(change.becameOnline)
        XCTAssertFalse(change.becameOffline)
    }

    func testConnectivityChangeDetectsBecameOffline() {
        let change = ConnectivityChange(previous: .online(), current: .offline())
        XCTAssertTrue(change.becameOffline)
        XCTAssertFalse(change.becameOnline)
    }

    func testConnectivityChangeDetectsCostChange() {
        let change = ConnectivityChange(
            previous: .online(isExpensive: false),
            current: .online(isExpensive: true)
        )
        XCTAssertTrue(change.costChanged)
    }

    func testChangeStreamEmitsTransitions() async {
        let monitor = ManualConnectivityMonitor(initialSnapshot: .offline())
        let changeStream = await ConnectivityChangeStream(monitor: monitor).changes()
        var iterator = changeStream.makeAsyncIterator()

        let first = await iterator.next()
        XCTAssertNil(first?.previous)
        XCTAssertEqual(first?.current.status, .offline)

        await monitor.update(.online())
        let second = await iterator.next()
        XCTAssertEqual(second?.previous?.status, .offline)
        XCTAssertEqual(second?.current.status, .online)
        XCTAssertEqual(second?.becameOnline, true)
    }

    func testWaiterReturnsImmediatelyWhenAlreadyAllowed() async {
        let monitor = StaticConnectivityMonitor(snapshot: .online())
        let snapshot = await ConnectivityWaiter(monitor: monitor).waitUntilAllowed()
        XCTAssertTrue(snapshot.isOnline)
    }

    func testWaiterSuspendsUntilAllowed() async {
        let monitor = ManualConnectivityMonitor(initialSnapshot: .offline())
        let task = Task {
            await ConnectivityWaiter(monitor: monitor).waitUntilAllowed()
        }

        await Task.yield()
        await monitor.update(.online(interfaces: [.wifi]))
        let snapshot = await task.value
        XCTAssertEqual(snapshot.status, .online)
        XCTAssertEqual(snapshot.interfaces, [.wifi])
    }

    func testDiagnosticSnapshotIsPrivacySafeAndCodable() throws {
        let snapshot = ConnectivitySnapshot.online(
            interfaces: [.wifi, .cellular],
            isExpensive: true,
            isConstrained: false
        )
        let diagnostic = snapshot.diagnosticSnapshot
        let data = try JSONEncoder().encode(diagnostic)
        let decoded = try JSONDecoder().decode(ConnectivityDiagnosticSnapshot.self, from: data)

        XCTAssertEqual(decoded.status, .online)
        XCTAssertEqual(decoded.interfaces, [.cellular, .wifi])
        XCTAssertTrue(decoded.isExpensive)
        XCTAssertFalse(decoded.isConstrained)
    }

    func testSnapshotIsCodable() throws {
        let snapshot = ConnectivitySnapshot.online(
            interfaces: [.wifi],
            isExpensive: false,
            isConstrained: true,
            timestamp: Date(timeIntervalSince1970: 100)
        )
        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(ConnectivitySnapshot.self, from: data)
        XCTAssertEqual(decoded, snapshot)
    }

    func testFactoryReturnsMonitor() async {
        let monitor = ConnectivityMonitorFactory.makeDefault()
        let snapshot = await monitor.currentSnapshot()
        XCTAssertTrue(ConnectivityStatus.allCases.contains(snapshot.status))
    }

    #if canImport(Network)
    func testNativeMonitorStartAndStopAreIdempotent() async {
        let monitor = NetworkPathConnectivityMonitor()

        await monitor.start()
        await monitor.start()
        await monitor.stop()
        await monitor.stop()

        let snapshot = await monitor.currentSnapshot()
        XCTAssertTrue(ConnectivityStatus.allCases.contains(snapshot.status))
    }
    #endif
}
