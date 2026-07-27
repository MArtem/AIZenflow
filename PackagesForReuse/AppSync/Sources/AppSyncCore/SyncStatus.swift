import Foundation

/// User/interface-visible status for the current sync cycle.
public enum SyncStatus: Sendable, Equatable {
    case idle
    case syncing(progress: Double, reason: SyncReason?)
    case completed(lastSyncDate: Date)
    case failed(message: String)
}

/// Reason a sync run was requested, used for status, observability, and prioritization.
public enum SyncReason: String, Codable, Sendable, Equatable {
    case appLaunch
    case manual
    case pullToRefresh
    case localMutation
    case networkRestored
    case realtimeEvent
    case backgroundTask
}
