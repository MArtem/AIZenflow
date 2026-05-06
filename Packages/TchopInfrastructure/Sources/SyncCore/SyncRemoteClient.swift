import Foundation

public protocol SyncRemoteClient: Sendable {
    func push(_ request: PushRequest) async throws -> PushResponse
    func pull(_ request: PullRequest) async throws -> PullResponse
}
