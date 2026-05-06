import Foundation

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
