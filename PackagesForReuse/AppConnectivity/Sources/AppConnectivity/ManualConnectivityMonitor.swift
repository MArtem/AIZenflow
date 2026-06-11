import Foundation

/// Test-friendly and preview-friendly connectivity monitor.
///
/// It is also the fallback implementation on platforms where native path monitoring is unavailable.
/// Unlike `NetworkPathConnectivityMonitor`, this actor is manually driven and can be reused in tests
/// after stop by creating new streams and calling `update(_:)`.
public actor ManualConnectivityMonitor: ConnectivityMonitoring, ConnectivityChecking {
    private var snapshot: ConnectivitySnapshot
    private let continuationStore = ConnectivityContinuationStore()
    private var isStarted = false

    public init(initialSnapshot: ConnectivitySnapshot = .unknown()) {
        self.snapshot = initialSnapshot
    }

    public func start() async {
        isStarted = true
    }

    public func stop() async {
        isStarted = false
        await continuationStore.finish()
    }

    public func currentSnapshot() async -> ConnectivitySnapshot {
        snapshot
    }

    public func snapshots() async -> AsyncStream<ConnectivitySnapshot> {
        await continuationStore.makeStream(currentSnapshot: snapshot)
    }

    public func update(_ snapshot: ConnectivitySnapshot) async {
        self.snapshot = snapshot
        await continuationStore.yield(snapshot)
    }

    public func updateStatus(
        _ status: ConnectivityStatus,
        interfaces: Set<ConnectivityInterfaceKind> = [],
        isExpensive: Bool = false,
        isConstrained: Bool = false,
        timestamp: Date = Date()
    ) async {
        await update(
            ConnectivitySnapshot(
                status: status,
                interfaces: interfaces,
                isExpensive: isExpensive,
                isConstrained: isConstrained,
                timestamp: timestamp
            )
        )
    }
}

/// A monitor that always returns the same snapshot.
public struct StaticConnectivityMonitor: ConnectivityMonitoring, ConnectivityChecking {
    private let snapshot: ConnectivitySnapshot

    public init(snapshot: ConnectivitySnapshot) {
        self.snapshot = snapshot
    }

    public func start() async {}
    public func stop() async {}

    public func currentSnapshot() async -> ConnectivitySnapshot {
        snapshot
    }

    public func snapshots() async -> AsyncStream<ConnectivitySnapshot> {
        AsyncStream { continuation in
            continuation.yield(snapshot)
            continuation.finish()
        }
    }

    public static let online = StaticConnectivityMonitor(snapshot: .online())
    public static let offline = StaticConnectivityMonitor(snapshot: .offline())
}
