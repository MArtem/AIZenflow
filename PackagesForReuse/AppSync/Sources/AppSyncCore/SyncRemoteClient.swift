import Foundation

/// Remote transport boundary used by `SyncEngine`.
///
/// Responsibilities:
/// Implementations push pending mutations and pull remote changes without exposing app-specific
/// networking details to the sync engine.
public protocol SyncRemoteClient: Sendable {
    func push(_ request: PushRequest) async throws -> PushResponse
    func pull(_ request: PullRequest) async throws -> PullResponse
}
