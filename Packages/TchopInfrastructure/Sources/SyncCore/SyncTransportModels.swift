import Foundation

/// Batch of local mutations sent to the remote sync endpoint.
public struct PushRequest: Codable, Sendable, Equatable {
    public let mutations: [SyncMutation]

    public init(mutations: [SyncMutation]) {
        self.mutations = mutations
    }
}

/// Per-mutation result returned by a push operation.
public enum MutationPushResult: Codable, Sendable, Equatable {
    case accepted(mutationID: UUID, entityID: String, serverRevision: Int?, serverUpdatedAt: Date?)
    case conflict(SyncConflict)
    case rejected(mutationID: UUID, reason: String)
}

/// Remote response for a pushed mutation batch.
public struct PushResponse: Codable, Sendable, Equatable {
    public let results: [MutationPushResult]

    public init(results: [MutationPushResult]) {
        self.results = results
    }
}

/// Request for remote changes after the last known cursor.
public struct PullRequest: Codable, Sendable, Equatable {
    public let cursor: SyncCursor?
    public let limit: Int

    public init(cursor: SyncCursor?, limit: Int = 500) {
        self.cursor = cursor
        self.limit = limit
    }
}

/// Remote change page plus the cursor needed for the next pull.
public struct PullResponse: Codable, Sendable, Equatable {
    public let changes: [RemoteChange]
    public let nextCursor: SyncCursor?
    public let hasMore: Bool
    public let serverTime: Date?

    public init(
        changes: [RemoteChange],
        nextCursor: SyncCursor?,
        hasMore: Bool,
        serverTime: Date? = nil
    ) {
        self.changes = changes
        self.nextCursor = nextCursor
        self.hasMore = hasMore
        self.serverTime = serverTime
    }
}
