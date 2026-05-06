import Foundation

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
