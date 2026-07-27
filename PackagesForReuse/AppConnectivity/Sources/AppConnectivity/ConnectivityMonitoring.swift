import Foundation

/// Main contract for observing connectivity in an app-independent way.
public protocol ConnectivityMonitoring: Sendable {
    func start() async
    func stop() async
    func currentSnapshot() async -> ConnectivitySnapshot
    func snapshots() async -> AsyncStream<ConnectivitySnapshot>
}

public extension ConnectivityMonitoring {
    func isOnline() async -> Bool {
        await currentSnapshot().isOnline
    }

    func isAllowed(by policy: ConnectivityCostPolicy) async -> Bool {
        await currentSnapshot().isAllowed(by: policy)
    }
}

/// Convenience contract for simple one-shot connectivity checks.
public protocol ConnectivityChecking: Sendable {
    func currentSnapshot() async -> ConnectivitySnapshot
}

extension ConnectivityMonitoring where Self: ConnectivityChecking {}
