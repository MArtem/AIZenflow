import Foundation

public protocol SyncEntity: Codable, Identifiable, Sendable where ID == String {
    static var syncEntityType: String { get }

    var id: String { get }
    var syncMetadata: SyncMetadata { get set }
}

public extension SyncEntity {
    var entityType: String { Self.syncEntityType }
}
