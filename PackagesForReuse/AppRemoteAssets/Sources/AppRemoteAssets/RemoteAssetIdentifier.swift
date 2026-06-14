import Foundation

public struct RemoteAssetID: Hashable, Codable, Sendable, CustomStringConvertible {
    public let value: String

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw RemoteAssetFailure(code: .emptyIdentifier)
        }
        guard trimmed.count <= 160 else {
            throw RemoteAssetFailure(code: .identifierTooLong)
        }
        guard Self.isSafe(trimmed) else {
            throw RemoteAssetFailure(code: .unsafeIdentifier)
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


    public var description: String {
        "RemoteAssetID(redacted)"
    }

    private static func isSafe(_ value: String) -> Bool {
        if value == "." || value == ".." || value.contains("../") || value.contains("..\\") {
            return false
        }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._:-")
        return value.unicodeScalars.allSatisfy { scalar in
            allowed.contains(scalar) && !CharacterSet.controlCharacters.contains(scalar)
        }
    }
}

public struct RemoteAssetVersion: Hashable, Codable, Sendable, CustomStringConvertible {
    public let value: String

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw RemoteAssetFailure(code: .emptyVersion)
        }
        guard trimmed.count <= 128 else {
            throw RemoteAssetFailure(code: .versionTooLong)
        }
        guard Self.isSafe(trimmed) else {
            throw RemoteAssetFailure(code: .unsafeVersion)
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


    public var description: String {
        "RemoteAssetVersion(redacted)"
    }

    private static func isSafe(_ value: String) -> Bool {
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._:+-")
        return value.unicodeScalars.allSatisfy { scalar in
            allowed.contains(scalar) && !CharacterSet.controlCharacters.contains(scalar)
        }
    }
}
