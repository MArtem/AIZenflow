import Foundation

/// Receives sync progress and counter updates without coupling the sync engine to a UI observation framework.
///
/// Ownership:
/// App or package composition supplies a reporter when status must be observed or recorded. `SyncEngine` uses the
/// default no-op reporter when a caller only needs synchronization behavior.
public protocol SyncStatusReporting: Sendable {
    /// Records the current sync lifecycle status.
    func setStatus(_ status: SyncStatus) async

    /// Records the number of queued local mutations.
    func setPendingChangesCount(_ count: Int) async

    /// Records the number of unresolved conflicts.
    func setUnresolvedConflictsCount(_ count: Int) async
}

/// Default reporter for sync flows that do not expose status to UI or diagnostics.
public struct SyncNoopStatusReporter: SyncStatusReporting {
    /// Creates a no-op sync status reporter.
    public init() {}

    public func setStatus(_ status: SyncStatus) async {}

    public func setPendingChangesCount(_ count: Int) async {}

    public func setUnresolvedConflictsCount(_ count: Int) async {}
}
