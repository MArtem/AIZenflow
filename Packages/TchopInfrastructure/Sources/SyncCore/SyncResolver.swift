import Foundation

public enum ConflictResolutionAction: Codable, Sendable, Equatable {
    case useLocal
    case useRemote
    case keepConflict
    case merged(payloadData: Data, fieldChanges: [FieldChange])
}

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

public protocol SyncResolving: Sendable {
    func resolve(_ conflict: SyncConflict) async throws -> ConflictResolution
}

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

public struct ServerWinsResolver: SyncResolving {
    public init() {}

    public func resolve(_ conflict: SyncConflict) async throws -> ConflictResolution {
        ConflictResolution(conflictID: conflict.id, action: .useRemote)
    }
}

public struct ClientWinsResolver: SyncResolving {
    public init() {}

    public func resolve(_ conflict: SyncConflict) async throws -> ConflictResolution {
        ConflictResolution(conflictID: conflict.id, action: .useLocal)
    }
}

public struct ManualConflictResolver: SyncResolving {
    public init() {}

    public func resolve(_ conflict: SyncConflict) async throws -> ConflictResolution {
        ConflictResolution(conflictID: conflict.id, action: .keepConflict)
    }
}
