import Foundation

/// Converts snapshot streams into transition events.
public struct ConnectivityChangeStream: Sendable {
    private let monitor: any ConnectivityMonitoring

    public init(monitor: any ConnectivityMonitoring) {
        self.monitor = monitor
    }

    public func changes() async -> AsyncStream<ConnectivityChange> {
        let stream = await monitor.snapshots()
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let task = Task {
                var previous: ConnectivitySnapshot?
                for await snapshot in stream {
                    continuation.yield(ConnectivityChange(previous: previous, current: snapshot))
                    previous = snapshot
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

/// Wait helper for code that should suspend until connectivity becomes usable.
///
/// The wait is owned by the caller task. Cancelling the caller task stops the wait; the helper does
/// not create a detached background lifecycle.
public struct ConnectivityWaiter: Sendable {
    private let monitor: any ConnectivityMonitoring
    private let policy: ConnectivityCostPolicy

    public init(
        monitor: any ConnectivityMonitoring,
        policy: ConnectivityCostPolicy = .permissive
    ) {
        self.monitor = monitor
        self.policy = policy
    }

    public func waitUntilAllowed() async -> ConnectivitySnapshot {
        let current = await monitor.currentSnapshot()
        if current.isAllowed(by: policy) {
            return current
        }

        let stream = await monitor.snapshots()
        for await snapshot in stream where snapshot.isAllowed(by: policy) {
            return snapshot
        }

        return await monitor.currentSnapshot()
    }
}
