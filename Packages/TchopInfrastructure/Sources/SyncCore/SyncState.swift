import Foundation

public enum SyncState: String, Codable, Sendable, Equatable, CaseIterable {
    case synced
    case pendingCreate
    case pendingUpdate
    case pendingDelete
    case conflict
    case failed
}
