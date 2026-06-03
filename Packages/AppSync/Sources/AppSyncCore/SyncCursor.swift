import Foundation

/// Opaque remote pagination cursor scoped to one sync stream.
///
/// Invariant:
/// `scope` must match the sync engine scope that saved it; cursors are not interchangeable across streams.
public struct SyncCursor: Codable, Sendable, Equatable, Hashable {
    public let scope: String
    public let value: String
    public let updatedAt: Date

    public init(scope: String, value: String, updatedAt: Date = Date()) {
        self.scope = scope
        self.value = value
        self.updatedAt = updatedAt
    }
}
