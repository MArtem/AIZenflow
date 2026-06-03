import Foundation

/// Local persistence boundary required by `SyncEngine`.
///
/// Responsibilities:
/// - provide pending local mutations;
/// - persist remote changes and cursors;
/// - store conflicts and apply resolutions.
public protocol SyncLocalStore: Sendable {
    func pendingMutations(limit: Int) async throws -> [SyncMutation]
    func pendingMutationsCount() async throws -> Int
    func unresolvedConflictsCount() async throws -> Int

    func markMutationsAsSynced(_ mutationIDs: [UUID]) async throws
    func markMutationAsFailed(_ mutationID: UUID, reason: String) async throws

    func saveConflict(_ conflict: SyncConflict) async throws
    func markConflictResolved(_ conflictID: UUID, resolution: ConflictResolution) async throws

    func loadCursor(scope: String) async throws -> SyncCursor?
    func saveRemoteChanges(_ changes: [RemoteChange], nextCursor: SyncCursor?) async throws

    func applyResolution(_ resolution: ConflictResolution) async throws
}
