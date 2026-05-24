import Foundation

/// Action selected by a conflict resolver for one unresolved conflict.
public enum ConflictResolutionAction: Codable, Sendable, Equatable {
    case useLocal
    case useRemote
    case keepConflict
    case merged(payloadData: Data, fieldChanges: [FieldChange])
}

/// Persistable decision produced after resolving a sync conflict.
public struct ConflictResolution: Codable, Sendable, Equatable {
    public let conflictID: UUID
    public let action: ConflictResolutionAction
    public let resolvedAt: Date

    public init(conflictID: UUID, action: ConflictResolutionAction, resolvedAt: Date = Date()) {
        self.conflictID = conflictID
        self.action = action
        self.resolvedAt = resolvedAt
    }
}

/// Strategy boundary for resolving sync conflicts.
public protocol SyncResolving: Sendable {
    func resolve(_ conflict: SyncConflict) async throws -> ConflictResolution
}

/// Conflict resolver that chooses the payload with the newest known timestamp.
///
/// Rationale:
/// Useful only when product semantics accept timestamp-based conflict resolution.
public struct LastWriteWinsResolver: SyncResolving {
    public init() {}

    public func resolve(_ conflict: SyncConflict) async throws -> ConflictResolution {
        let localDate = conflict.localMutation?.createdAt ?? .distantPast
        let remoteDate = conflict.remoteChange?.serverUpdatedAt ?? .distantPast

        if localDate > remoteDate {
            return ConflictResolution(conflictID: conflict.id, action: .useLocal)
        } else {
            return ConflictResolution(conflictID: conflict.id, action: .useRemote)
        }
    }
}

/// Conflict resolver that always keeps the remote/server version.
public struct ServerWinsResolver: SyncResolving {
    public init() {}

    public func resolve(_ conflict: SyncConflict) async throws -> ConflictResolution {
        ConflictResolution(conflictID: conflict.id, action: .useRemote)
    }
}

/// Conflict resolver that always keeps the local/client version.
public struct ClientWinsResolver: SyncResolving {
    public init() {}

    public func resolve(_ conflict: SyncConflict) async throws -> ConflictResolution {
        ConflictResolution(conflictID: conflict.id, action: .useLocal)
    }
}

/// Conflict resolver that preserves conflicts for explicit app/user handling.
public struct ManualConflictResolver: SyncResolving {
    public init() {}

    public func resolve(_ conflict: SyncConflict) async throws -> ConflictResolution {
        ConflictResolution(conflictID: conflict.id, action: .keepConflict)
    }
}
