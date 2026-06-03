import Foundation

/// Per-entity sync bookkeeping persisted alongside synced domain data.
///
/// Invariant:
/// Local revision advances on local changes; server/base revisions represent the remote baseline
/// used to detect stale updates and conflicts.
public struct SyncMetadata: Codable, Sendable, Equatable {
    public var state: SyncState
    public var localRevision: Int
    public var serverRevision: Int?
    public var baseServerRevision: Int?
    public var updatedAt: Date
    public var serverUpdatedAt: Date?
    public var lastSyncError: String?

    public init(
        state: SyncState = .synced,
        localRevision: Int = 0,
        serverRevision: Int? = nil,
        baseServerRevision: Int? = nil,
        updatedAt: Date = Date(),
        serverUpdatedAt: Date? = nil,
        lastSyncError: String? = nil
    ) {
        self.state = state
        self.localRevision = localRevision
        self.serverRevision = serverRevision
        self.baseServerRevision = baseServerRevision
        self.updatedAt = updatedAt
        self.serverUpdatedAt = serverUpdatedAt
        self.lastSyncError = lastSyncError
    }

    public mutating func markLocalChange(state: SyncState, at date: Date = Date()) {
        self.state = state
        self.localRevision += 1
        self.updatedAt = date
        self.lastSyncError = nil
        if self.baseServerRevision == nil {
            self.baseServerRevision = self.serverRevision
        }
    }

    public mutating func markSynced(serverRevision: Int?, serverUpdatedAt: Date?, at date: Date = Date()) {
        self.state = .synced
        self.serverRevision = serverRevision
        self.baseServerRevision = serverRevision
        self.serverUpdatedAt = serverUpdatedAt
        self.updatedAt = date
        self.lastSyncError = nil
    }

    public mutating func markConflict(error: String? = nil) {
        self.state = .conflict
        self.lastSyncError = error
    }

    public mutating func markFailed(_ error: String) {
        self.state = .failed
        self.lastSyncError = error
    }
}
