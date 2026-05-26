import Foundation
import SyncCore
import Testing

/// Validates generic sync models, conflict resolution, and engine orchestration.
struct SyncCoreTests {
    @Test
    func fieldValueRoundTripsThroughCodableDiscriminator() throws {
        let date = Date(timeIntervalSince1970: 1_234)
        let values: [FieldValue] = [
            .string("title"),
            .int(42),
            .double(3.14),
            .bool(true),
            .date(date),
            .null,
            .stringArray(["a", "b"]),
            .data(Data([1, 2, 3]))
        ]

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for value in values {
            let data = try encoder.encode(value)
            let decoded = try decoder.decode(FieldValue.self, from: data)

            #expect(decoded == value)
        }
    }

    @Test
    func syncMetadataTransitionsPreserveRevisionAndBaselineRules() {
        let initialServerDate = Date(timeIntervalSince1970: 10)
        let localChangeDate = Date(timeIntervalSince1970: 20)
        let syncedDate = Date(timeIntervalSince1970: 30)

        var metadata = SyncMetadata(
            state: .synced,
            localRevision: 3,
            serverRevision: 7,
            serverUpdatedAt: initialServerDate
        )

        metadata.markLocalChange(state: .pendingUpdate, at: localChangeDate)

        #expect(metadata.state == .pendingUpdate)
        #expect(metadata.localRevision == 4)
        #expect(metadata.baseServerRevision == 7)
        #expect(metadata.updatedAt == localChangeDate)
        #expect(metadata.lastSyncError == nil)

        metadata.markFailed("network")
        #expect(metadata.state == .failed)
        #expect(metadata.lastSyncError == "network")

        metadata.markConflict(error: "stale")
        #expect(metadata.state == .conflict)
        #expect(metadata.lastSyncError == "stale")

        metadata.markSynced(serverRevision: 8, serverUpdatedAt: syncedDate, at: syncedDate)
        #expect(metadata.state == .synced)
        #expect(metadata.serverRevision == 8)
        #expect(metadata.baseServerRevision == 8)
        #expect(metadata.serverUpdatedAt == syncedDate)
        #expect(metadata.updatedAt == syncedDate)
        #expect(metadata.lastSyncError == nil)
    }

    @Test
    func conflictResolversProduceExpectedActions() async throws {
        let conflictID = UUID()
        let oldLocalMutation = SyncMutation(
            entityType: "card",
            entityID: "1",
            operation: .update,
            baseServerRevision: 1,
            createdAt: Date(timeIntervalSince1970: 10)
        )
        let newRemoteChange = RemoteChange(
            entityType: "card",
            entityID: "1",
            kind: .updated,
            serverRevision: 2,
            serverUpdatedAt: Date(timeIntervalSince1970: 20)
        )
        let conflict = SyncConflict(
            id: conflictID,
            entityType: "card",
            entityID: "1",
            reason: .staleBaseRevision,
            localMutation: oldLocalMutation,
            remoteChange: newRemoteChange
        )

        let lastWriteWins = try await LastWriteWinsResolver().resolve(conflict)
        let serverWins = try await ServerWinsResolver().resolve(conflict)
        let clientWins = try await ClientWinsResolver().resolve(conflict)
        let manual = try await ManualConflictResolver().resolve(conflict)

        #expect(lastWriteWins.action == .useRemote)
        #expect(serverWins.action == .useRemote)
        #expect(clientWins.action == .useLocal)
        #expect(manual.action == .keepConflict)
        #expect(lastWriteWins.conflictID == conflictID)
    }

    @MainActor
    @Test
    func syncEnginePushesPendingMutationsPullsRemoteChangesAndUpdatesStatus() async throws {
        let mutation = SyncMutation(
            entityType: "card",
            entityID: "card-1",
            operation: .update,
            baseServerRevision: 1
        )
        let cursor = SyncCursor(scope: "feed", value: "next")
        let remoteChange = RemoteChange(
            entityType: "card",
            entityID: "card-2",
            kind: .created,
            serverRevision: 2,
            serverUpdatedAt: Date(timeIntervalSince1970: 40),
            payloadData: Data([9])
        )
        let localStore = MemorySyncLocalStore(pending: [mutation])
        let remoteClient = MemorySyncRemoteClient(
            pushResponse: PushResponse(results: [
                .accepted(
                    mutationID: mutation.id,
                    entityID: mutation.entityID,
                    serverRevision: 2,
                    serverUpdatedAt: Date(timeIntervalSince1970: 50)
                )
            ]),
            pullResponses: [
                PullResponse(
                    changes: [remoteChange],
                    nextCursor: cursor,
                    hasMore: false
                )
            ]
        )
        let statusStore = SyncStatusStore()
        let engine = SyncEngine(
            localStore: localStore,
            remoteClient: remoteClient,
            statusStore: statusStore,
            scope: "feed",
            batchSize: 10
        )

        await engine.sync(reason: .manual)

        let syncedIDs = await localStore.syncedMutationIDs
        let savedChanges = await localStore.savedRemoteChanges
        let savedCursor = await localStore.savedCursor
        let pushRequests = await remoteClient.pushRequests
        let pullRequests = await remoteClient.pullRequests

        #expect(syncedIDs == [mutation.id])
        #expect(savedChanges == [remoteChange])
        #expect(savedCursor == cursor)
        #expect(pushRequests == [PushRequest(mutations: [mutation])])
        #expect(pullRequests == [PullRequest(cursor: nil, limit: 10)])
        #expect(statusStore.pendingChangesCount == 0)
        #expect(statusStore.unresolvedConflictsCount == 0)

        if case .completed(let lastSyncDate) = statusStore.status {
            #expect(statusStore.lastSyncDate == lastSyncDate)
            #expect(statusStore.lastErrorMessage == nil)
        } else {
            Issue.record("Expected completed sync status")
        }
    }
}

private actor MemorySyncLocalStore: SyncLocalStore {
    private var pending: [SyncMutation]
    private(set) var syncedMutationIDs: [UUID] = []
    private(set) var savedRemoteChanges: [RemoteChange] = []
    private(set) var savedCursor: SyncCursor?

    init(pending: [SyncMutation]) {
        self.pending = pending
    }

    func pendingMutations(limit: Int) async throws -> [SyncMutation] {
        Array(pending.prefix(limit))
    }

    func pendingMutationsCount() async throws -> Int {
        pending.count
    }

    func unresolvedConflictsCount() async throws -> Int {
        0
    }

    func markMutationsAsSynced(_ mutationIDs: [UUID]) async throws {
        syncedMutationIDs.append(contentsOf: mutationIDs)
        pending.removeAll { mutationIDs.contains($0.id) }
    }

    func markMutationAsFailed(_ mutationID: UUID, reason: String) async throws {
        pending.removeAll { $0.id == mutationID }
    }

    func saveConflict(_ conflict: SyncConflict) async throws {}

    func markConflictResolved(_ conflictID: UUID, resolution: ConflictResolution) async throws {}

    func loadCursor(scope: String) async throws -> SyncCursor? {
        nil
    }

    func saveRemoteChanges(_ changes: [RemoteChange], nextCursor: SyncCursor?) async throws {
        savedRemoteChanges.append(contentsOf: changes)
        savedCursor = nextCursor
    }

    func applyResolution(_ resolution: ConflictResolution) async throws {}
}

private actor MemorySyncRemoteClient: SyncRemoteClient {
    private let pushResponse: PushResponse
    private var queuedPullResponses: [PullResponse]
    private(set) var pushRequests: [PushRequest] = []
    private(set) var pullRequests: [PullRequest] = []

    init(pushResponse: PushResponse, pullResponses: [PullResponse]) {
        self.pushResponse = pushResponse
        self.queuedPullResponses = pullResponses
    }

    func push(_ request: PushRequest) async throws -> PushResponse {
        pushRequests.append(request)
        return pushResponse
    }

    func pull(_ request: PullRequest) async throws -> PullResponse {
        pullRequests.append(request)
        return queuedPullResponses.removeFirst()
    }
}
