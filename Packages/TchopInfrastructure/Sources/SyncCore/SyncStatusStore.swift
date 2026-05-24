import Foundation
import Observation

@MainActor
@Observable
/// Main-actor observable status owner for sync progress and counters.
///
/// Ownership:
/// Owned by app/package composition and observed by UI or diagnostics surfaces that display sync state.
public final class SyncStatusStore {
    public private(set) var status: SyncStatus = .idle
    public private(set) var pendingChangesCount: Int = 0
    public private(set) var unresolvedConflictsCount: Int = 0
    public private(set) var lastSyncDate: Date?
    public private(set) var lastErrorMessage: String?

    public init() {}

        /// Updates the user-visible sync status and derived last-sync/error fields.
public func setStatus(_ status: SyncStatus) {
        self.status = status

        switch status {
        case .completed(let date):
            self.lastSyncDate = date
            self.lastErrorMessage = nil
        case .failed(let message):
            self.lastErrorMessage = message
        case .idle, .syncing:
            break
        }
    }

        /// Updates the number of queued local mutations exposed to UI/diagnostics.
public func setPendingChangesCount(_ count: Int) {
        self.pendingChangesCount = count
    }

        /// Updates the number of unresolved conflicts exposed to UI/diagnostics.
public func setUnresolvedConflictsCount(_ count: Int) {
        self.unresolvedConflictsCount = count
    }
}
