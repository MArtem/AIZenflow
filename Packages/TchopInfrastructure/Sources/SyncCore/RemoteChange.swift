import Foundation

/// Operation kind reported by the remote sync source.
public enum RemoteChangeKind: String, Codable, Sendable, Equatable {
    case created
    case updated
    case deleted
}

/// Remote-side entity change pulled into the local store.
///
/// External usage:
/// Returned by `SyncRemoteClient.pull(_:)` and applied by `SyncLocalStore.saveRemoteChanges(_:nextCursor:)`.
public struct RemoteChange: Codable, Identifiable, Sendable, Equatable {
    public var id: String { "\(entityType):\(entityID):\(serverRevision ?? -1)" }
    public let entityType: String
    public let entityID: String
    public let kind: RemoteChangeKind
    public let serverRevision: Int?
    public let serverUpdatedAt: Date?
    public let payloadData: Data?
    public let tombstone: SyncTombstone?

    public init(
        entityType: String,
        entityID: String,
        kind: RemoteChangeKind,
        serverRevision: Int?,
        serverUpdatedAt: Date?,
        payloadData: Data? = nil,
        tombstone: SyncTombstone? = nil
    ) {
        self.entityType = entityType
        self.entityID = entityID
        self.kind = kind
        self.serverRevision = serverRevision
        self.serverUpdatedAt = serverUpdatedAt
        self.payloadData = payloadData
        self.tombstone = tombstone
    }
}
