import Foundation

/// Describes one field-level mutation inside a sync operation.
///
/// External usage:
/// Produced by local stores when recording pending mutations and consumed by sync resolvers/remotes
/// to understand what changed without decoding the full entity payload.
public struct FieldChange: Codable, Identifiable, Sendable, Equatable {
    public var id: String { name }
    public let name: String
    public let oldValue: FieldValue?
    public let newValue: FieldValue

    public init(name: String, oldValue: FieldValue? = nil, newValue: FieldValue) {
        self.name = name
        self.oldValue = oldValue
        self.newValue = newValue
    }
}
