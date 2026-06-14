import Foundation

public struct RemoteAssetMediaType: Hashable, Codable, Sendable, CustomStringConvertible {
    public let value: String

    public static let binary = Self(unchecked: "application/octet-stream")
    public static let json = Self(unchecked: "application/json")
    public static let png = Self(unchecked: "image/png")
    public static let jpeg = Self(unchecked: "image/jpeg")

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty, trimmed.count <= 128, trimmed.contains("/") else {
            throw RemoteAssetFailure(code: .unsafeMediaType)
        }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789!#$&^_.+-/;=")
        guard trimmed.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            throw RemoteAssetFailure(code: .unsafeMediaType)
        }
        self.value = trimmed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try Self(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }

    private init(unchecked value: String) {
        self.value = value
    }

    public var description: String {
        "RemoteAssetMediaType(\(value))"
    }
}
