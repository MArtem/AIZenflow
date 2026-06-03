import Foundation

/// Local mutation operation kind understood by generic sync transport.
public enum SyncOperationKind: String, Codable, Sendable, Equatable, CaseIterable {
    case create
    case update
    case delete
}
