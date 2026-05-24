import Foundation

/// Persisted per-entity sync state used to distinguish synced, pending, failed, and conflicted data.
public enum SyncState: String, Codable, Sendable, Equatable, CaseIterable {
    case synced
    case pendingCreate
    case pendingUpdate
    case pendingDelete
    case conflict
    case failed
}
