import Foundation

/// Deletion marker transported through sync so deletes can propagate without the original payload.
public struct SyncTombstone: Codable, Identifiable, Sendable, Equatable {
    public var id: String { "\(entityType):\(entityID)" }
    public let entityType: String
    public let entityID: String
    public let deletedAt: Date
    public let serverRevision: Int?
    public let deviceID: String?

    public init(
        entityType: String,
        entityID: String,
        deletedAt: Date = Date(),
        serverRevision: Int? = nil,
        deviceID: String? = nil
    ) {
        self.entityType = entityType
        self.entityID = entityID
        self.deletedAt = deletedAt
        self.serverRevision = serverRevision
        self.deviceID = deviceID
    }
}
