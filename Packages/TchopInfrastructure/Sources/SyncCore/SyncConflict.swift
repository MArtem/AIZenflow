import Foundation

public enum SyncConflictReason: String, Codable, Sendable, Equatable {
    case staleBaseRevision
    case fieldOverlap
    case deletedRemotelyUpdatedLocally
    case updatedRemotelyDeletedLocally
    case validationRejected
    case unknown
}

public struct SyncConflict: Codable, Identifiable, Sendable, Equatable {
    public let id: UUID
    public let entityType: String
    public let entityID: String
    public let reason: SyncConflictReason
    public let localMutation: SyncMutation?
    public let localPayloadData: Data?
    public let remoteChange: RemoteChange?
    public let createdAt: Date
    public let message: String?

    public init(
        id: UUID = UUID(),
        entityType: String,
        entityID: String,
        reason: SyncConflictReason,
        localMutation: SyncMutation? = nil,
        localPayloadData: Data? = nil,
        remoteChange: RemoteChange? = nil,
        createdAt: Date = Date(),
        message: String? = nil
    ) {
        self.id = id
        self.entityType = entityType
        self.entityID = entityID
        self.reason = reason
        self.localMutation = localMutation
        self.localPayloadData = localPayloadData
        self.remoteChange = remoteChange
        self.createdAt = createdAt
        self.message = message
    }
}
