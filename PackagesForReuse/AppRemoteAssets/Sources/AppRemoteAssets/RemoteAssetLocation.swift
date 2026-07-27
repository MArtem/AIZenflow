import Foundation

public struct RemoteAssetLocation: Hashable, Codable, Sendable, CustomStringConvertible {
    public let url: URL

    public init(url: URL, allowedSchemes: Set<String> = ["https"]) throws {
        let normalizedSchemes = Set(allowedSchemes.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
        guard normalizedSchemes.isEmpty == false else {
            throw RemoteAssetFailure(code: .unsupportedURLScheme)
        }
        guard let scheme = url.scheme?.lowercased(), normalizedSchemes.contains(scheme) else {
            throw RemoteAssetFailure(code: .unsupportedURLScheme)
        }
        self.url = url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try Self(url: try container.decode(URL.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url)
    }

    public var redactedURLString: String {
        RemoteAssetURLRedactor.redacted(url)
    }

    public var description: String {
        "RemoteAssetLocation(\(redactedURLString))"
    }
}
