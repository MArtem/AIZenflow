import Foundation

/// Coordinates push, pull, conflict resolution, and status updates for one sync scope.
///
/// Ownership:
/// Owned by app/package composition and usually driven by `SyncScheduler` or explicit refresh flows.
///
/// Concurrency:
/// Actor isolation serializes sync runs and prevents overlapping push/pull cycles.
public actor SyncEngine {
    private let localStore: SyncLocalStore
    private let remoteClient: SyncRemoteClient
    private let resolver: SyncResolving
    private let statusStore: SyncStatusStore
    private let scope: String
    private let batchSize: Int

    private var isRunning = false

    public init(
        localStore: SyncLocalStore,
        remoteClient: SyncRemoteClient,
        resolver: SyncResolving = ManualConflictResolver(),
        statusStore: SyncStatusStore,
        scope: String = "default",
        batchSize: Int = 500
    ) {
        self.localStore = localStore
        self.remoteClient = remoteClient
        self.resolver = resolver
        self.statusStore = statusStore
        self.scope = scope
        self.batchSize = batchSize
    }

        /// Runs one complete push/pull sync cycle if no sync is already running.
    ///
    /// External usage:
    /// Called by `SyncScheduler` or explicit app refresh flows.
    ///
    /// Side effects:
    /// Pushes pending mutations, stores remote changes, resolves conflicts, updates sync status.
public func sync(reason: SyncReason? = nil) async {
        guard !isRunning else { return }
        isRunning = true

        await statusStore.setStatus(.syncing(progress: 0.0, reason: reason))

        do {
            try await refreshCounters()

            await statusStore.setStatus(.syncing(progress: 0.15, reason: reason))
            try await pushPendingMutations()

            await statusStore.setStatus(.syncing(progress: 0.55, reason: reason))
            try await pullRemoteChangesUntilComplete()

            try await refreshCounters()
            let date = Date()
            await statusStore.setStatus(.completed(lastSyncDate: date))
        } catch is CancellationError {
            await statusStore.setStatus(.failed(message: SyncError.cancelled.localizedDescription))
        } catch {
            await statusStore.setStatus(.failed(message: error.localizedDescription))
        }

        isRunning = false
    }

    private func pushPendingMutations() async throws {
        while true {
            try Task.checkCancellation()
            let mutations = try await localStore.pendingMutations(limit: batchSize)
            guard !mutations.isEmpty else { return }

            let response = try await remoteClient.push(PushRequest(mutations: mutations))

            var syncedIDs: [UUID] = []

            for result in response.results {
                switch result {
                case .accepted(let mutationID, _, _, _):
                    syncedIDs.append(mutationID)

                case .conflict(let conflict):
                    try await localStore.saveConflict(conflict)
                    let resolution = try await resolver.resolve(conflict)
                    try await localStore.applyResolution(resolution)
                    try await localStore.markConflictResolved(conflict.id, resolution: resolution)

                case .rejected(let mutationID, let reason):
                    try await localStore.markMutationAsFailed(mutationID, reason: reason)
                }
            }

            if !syncedIDs.isEmpty {
                try await localStore.markMutationsAsSynced(syncedIDs)
            }

            if mutations.count < batchSize { return }
        }
    }

    private func pullRemoteChangesUntilComplete() async throws {
        var cursor = try await localStore.loadCursor(scope: scope)

        while true {
            try Task.checkCancellation()
            let response = try await remoteClient.pull(PullRequest(cursor: cursor, limit: batchSize))
            try await localStore.saveRemoteChanges(response.changes, nextCursor: response.nextCursor)

            cursor = response.nextCursor
            if !response.hasMore { return }
        }
    }

    private func refreshCounters() async throws {
        let pending = try await localStore.pendingMutationsCount()
        let conflicts = try await localStore.unresolvedConflictsCount()
        await statusStore.setPendingChangesCount(pending)
        await statusStore.setUnresolvedConflictsCount(conflicts)
    }
}
