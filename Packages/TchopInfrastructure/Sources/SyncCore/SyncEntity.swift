import Foundation

/// Entity contract for models that participate in generic offline sync.
///
/// Contract:
/// Conforming models expose stable string identity and mutable sync metadata while keeping
/// app-specific payload fields outside the sync engine.
public protocol SyncEntity: Codable, Identifiable, Sendable where ID == String {
    static var syncEntityType: String { get }

    var id: String { get }
    var syncMetadata: SyncMetadata { get set }
}

public extension SyncEntity {
    var entityType: String { Self.syncEntityType }
}
