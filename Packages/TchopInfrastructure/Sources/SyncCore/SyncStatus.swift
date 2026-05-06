import Foundation

public enum SyncStatus: Sendable, Equatable {
    case idle
    case syncing(progress: Double, reason: SyncReason?)
    case completed(lastSyncDate: Date)
    case failed(message: String)
}

public enum SyncReason: String, Codable, Sendable, Equatable {
    case appLaunch
    case manual
    case pullToRefresh
    case localMutation
    case networkRestored
    case realtimeEvent
    case backgroundTask
}
