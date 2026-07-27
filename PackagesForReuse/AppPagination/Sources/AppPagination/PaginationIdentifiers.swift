import Foundation

public struct PaginationCollectionID: SafePaginationIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafePaginationIdentifierValidator.validate(rawValue, label: "collection")
        self.rawValue = rawValue
    }
}

public struct PaginationCursor: SafePaginationIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafePaginationIdentifierValidator.validate(rawValue, label: "cursor", maximumLength: 512)
        self.rawValue = rawValue
    }
}

extension PaginationCollectionID {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension PaginationCursor {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
