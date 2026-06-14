import Foundation

public struct RemoteAssetManifestRequest: Hashable, Sendable, CustomStringConvertible {
    public let url: URL
    public let acceptedStatusCodes: ClosedRange<Int>
    public let maximumResponseBytes: Int
    public let allowedSchemes: Set<String>

    public init(
        url: URL,
        acceptedStatusCodes: ClosedRange<Int> = 200...299,
        maximumResponseBytes: Int = 1_000_000,
        allowedSchemes: Set<String> = ["https"]
    ) throws {
        let normalizedSchemes = Set(allowedSchemes.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
        guard normalizedSchemes.isEmpty == false else {
            throw RemoteAssetFailure(code: .unsupportedURLScheme)
        }
        guard let scheme = url.scheme?.lowercased(), normalizedSchemes.contains(scheme) else {
            throw RemoteAssetFailure(code: .unsupportedURLScheme)
        }
        guard acceptedStatusCodes.lowerBound >= 100, acceptedStatusCodes.upperBound <= 599 else {
            throw RemoteAssetFailure(code: .unacceptableStatusCode)
        }
        guard maximumResponseBytes > 0 else {
            throw RemoteAssetFailure(code: .invalidByteCount)
        }
        self.url = url
        self.acceptedStatusCodes = acceptedStatusCodes
        self.maximumResponseBytes = maximumResponseBytes
        self.allowedSchemes = normalizedSchemes
    }

    public var redactedURLString: String {
        RemoteAssetURLRedactor.redacted(url)
    }

    public var description: String {
        "RemoteAssetManifestRequest(url: \(redactedURLString), maximumResponseBytes: \(maximumResponseBytes))"
    }
}
