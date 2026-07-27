import Foundation

public struct RemoteAssetChecksum: Hashable, Codable, Sendable, CustomStringConvertible {
    public enum Algorithm: String, Codable, Sendable {
        case sha256
        case sha384
        case sha512
    }

    public let algorithm: Algorithm
    public let value: String

    public init(algorithm: Algorithm, value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count == algorithm.hexCharacterCount else {
            throw RemoteAssetFailure(code: .invalidManifest, context: "checksum")
        }
        let hex = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        guard trimmed.unicodeScalars.allSatisfy({ hex.contains($0) }) else {
            throw RemoteAssetFailure(code: .invalidManifest, context: "checksum")
        }
        self.algorithm = algorithm
        self.value = trimmed
    }

    private enum CodingKeys: String, CodingKey {
        case algorithm
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = try Self(
            algorithm: container.decode(Algorithm.self, forKey: .algorithm),
            value: container.decode(String.self, forKey: .value)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(algorithm, forKey: .algorithm)
        try container.encode(value, forKey: .value)
    }

    public var description: String {
        "RemoteAssetChecksum(algorithm: \(algorithm.rawValue), value: redacted)"
    }
}

extension RemoteAssetChecksum.Algorithm {
    var hexCharacterCount: Int {
        switch self {
        case .sha256:
            64
        case .sha384:
            96
        case .sha512:
            128
        }
    }
}
