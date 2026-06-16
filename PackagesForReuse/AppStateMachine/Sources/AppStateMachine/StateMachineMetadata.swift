import Foundation

public struct StateMetadata: Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public static let maximumEncodedBytes = 16_384

    public static let empty = StateMetadata(fields: [:])

    public let fields: [String: String]

    private init(fields: [String: String]) {
        self.fields = fields
    }

    public init(_ fields: [String: String] = [:]) throws {
        for key in fields.keys {
            try SafeIdentifierValidator.validate(key, label: "metadataKey")
        }
        let encodedSize = fields.reduce(0) { partial, item in
            partial + item.key.utf8.count + item.value.utf8.count
        }
        guard encodedSize <= Self.maximumEncodedBytes else {
            throw StateMachineFailure.metadataLimitExceeded(maximumBytes: Self.maximumEncodedBytes)
        }
        self.fields = fields
    }

    public var description: String {
        "<redacted:StateMetadata,count:\(fields.count)>"
    }

    public var debugDescription: String { description }
}

extension StateMetadata: Codable {
    private enum CodingKeys: String, CodingKey {
        case fields
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fields = try container.decode([String: String].self, forKey: .fields)
        try self.init(fields)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fields, forKey: .fields)
    }
}
