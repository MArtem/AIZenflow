import Foundation

public enum SyncOperationKind: String, Codable, Sendable, Equatable, CaseIterable {
    case create
    case update
    case delete
}
