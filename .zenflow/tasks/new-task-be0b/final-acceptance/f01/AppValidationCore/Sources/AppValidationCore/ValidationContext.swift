import Foundation

public struct ValidationContext: Equatable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    private var valuesByID: [ValidationValueID: ValidationValue]

    public init() {
        self.valuesByID = [:]
    }

    public init(values: [NamedValidationValue]) throws {
        var storage: [ValidationValueID: ValidationValue] = [:]
        for value in values {
            guard storage[value.id] == nil else {
                throw ValidationFailure.invalidContext(reason: .duplicateValue)
            }
            storage[value.id] = value.value
        }
        self.valuesByID = storage
    }

    public func value(for id: ValidationValueID) -> ValidationValue? {
        valuesByID[id]
    }

    public var allValues: [ValidationValueID: ValidationValue] {
        valuesByID
    }

    public var description: String {
        "ValidationContext(valueCount: \(valuesByID.count), values: redacted)"
    }

    public var debugDescription: String {
        description
    }
}
