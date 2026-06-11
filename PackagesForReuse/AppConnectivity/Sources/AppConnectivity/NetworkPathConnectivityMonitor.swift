#if canImport(Network)
@preconcurrency import Network
import Dispatch
import Foundation

/// Native Network.framework-backed connectivity monitor.
///
/// This type is an actor to keep `NWPathMonitor` access behind an explicit isolation boundary
/// instead of using unchecked Sendable on the public monitor type. It is available only on
/// platforms where `Network.framework` is available.
public actor NetworkPathConnectivityMonitor: ConnectivityMonitoring, ConnectivityChecking {
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    private let state: NetworkPathConnectivityState
    private let clock: @Sendable () -> Date
    private var lifecycle: MonitorLifecycle = .idle

    public init(
        requiredInterfaceType: NWInterface.InterfaceType? = nil,
        queueLabel: String = "app.connectivity.network-path-monitor",
        clock: @escaping @Sendable () -> Date = { Date() }
    ) {
        if let requiredInterfaceType {
            self.monitor = NWPathMonitor(requiredInterfaceType: requiredInterfaceType)
        } else {
            self.monitor = NWPathMonitor()
        }
        self.queue = DispatchQueue(label: queueLabel)
        self.state = NetworkPathConnectivityState(initialSnapshot: .unknown(timestamp: clock()))
        self.clock = clock
    }

    /// Starts native path monitoring once.
    ///
    /// `NWPathMonitor` is not a reusable start/stop object after cancellation. This method is
    /// idempotent while the monitor is active and intentionally does not restart after `stop()`;
    /// create a new `NetworkPathConnectivityMonitor` instance for a fresh native monitor lifecycle.
    public func start() async {
        guard lifecycle == .idle else {
            return
        }
        lifecycle = .started
        let state = state
        let clock = clock
        monitor.pathUpdateHandler = { path in
            let snapshot = Self.makeSnapshot(from: path, timestamp: clock())
            Task { await state.update(snapshot) }
        }
        monitor.start(queue: queue)
    }

    /// Stops native path monitoring and finishes current streams.
    ///
    /// After stop, this instance is terminal because the underlying `NWPathMonitor` has been
    /// cancelled. Use `ConnectivityMonitorFactory.makeDefault()` or a new initializer call for
    /// another monitoring lifecycle.
    public func stop() async {
        guard lifecycle == .started else {
            if lifecycle == .idle {
                lifecycle = .stopped
                await state.finish()
            }
            return
        }
        lifecycle = .stopped
        monitor.cancel()
        await state.finish()
    }

    public func currentSnapshot() async -> ConnectivitySnapshot {
        await state.currentSnapshot()
    }

    public func snapshots() async -> AsyncStream<ConnectivitySnapshot> {
        await state.snapshots()
    }

    private static func makeSnapshot(from path: NWPath, timestamp: Date) -> ConnectivitySnapshot {
        let status: ConnectivityStatus
        switch path.status {
        case .satisfied:
            status = .online
        case .unsatisfied:
            status = .offline
        case .requiresConnection:
            status = .requiresConnection
        @unknown default:
            status = .unknown
        }

        var interfaces = Set<ConnectivityInterfaceKind>()
        if path.usesInterfaceType(.wifi) { interfaces.insert(.wifi) }
        if path.usesInterfaceType(.cellular) { interfaces.insert(.cellular) }
        if path.usesInterfaceType(.wiredEthernet) { interfaces.insert(.wiredEthernet) }
        if path.usesInterfaceType(.loopback) { interfaces.insert(.loopback) }
        if path.usesInterfaceType(.other) { interfaces.insert(.other) }
        if interfaces.isEmpty && status == .online { interfaces.insert(.unknown) }

        return ConnectivitySnapshot(
            status: status,
            interfaces: interfaces,
            isExpensive: path.isExpensive,
            isConstrained: path.isConstrained,
            timestamp: timestamp
        )
    }
}

private enum MonitorLifecycle: Sendable {
    case idle
    case started
    case stopped
}

private actor NetworkPathConnectivityState {
    private var snapshot: ConnectivitySnapshot
    private let continuationStore = ConnectivityContinuationStore()

    init(initialSnapshot: ConnectivitySnapshot) {
        self.snapshot = initialSnapshot
    }

    func currentSnapshot() -> ConnectivitySnapshot {
        snapshot
    }

    func snapshots() async -> AsyncStream<ConnectivitySnapshot> {
        await continuationStore.makeStream(currentSnapshot: snapshot)
    }

    func update(_ snapshot: ConnectivitySnapshot) async {
        self.snapshot = snapshot
        await continuationStore.yield(snapshot)
    }

    func finish() async {
        await continuationStore.finish()
    }
}
#endif
