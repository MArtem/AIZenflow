import Foundation

public struct DownloadRequest: Equatable, Sendable, CustomStringConvertible {
    public let id: DownloadID
    public let url: URL
    public let maximumAllowedBytes: Int64?
    public let allowedSchemes: Set<String>

    public init(
        id: DownloadID = .generated(),
        url: URL,
        maximumAllowedBytes: Int64? = nil,
        allowedSchemes: Set<String> = ["https"]
    ) throws {
        let normalizedSchemes = Set(allowedSchemes.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
        guard normalizedSchemes.isEmpty == false else {
            throw DownloadFailure(.invalidURL, operation: .validation)
        }
        guard let scheme = url.scheme?.lowercased(), normalizedSchemes.contains(scheme) else {
            throw DownloadFailure(.invalidURL, operation: .validation)
        }
        if let maximumAllowedBytes {
            guard maximumAllowedBytes > 0 else {
                throw DownloadFailure(.responseTooLarge, operation: .validation)
            }
        }
        self.id = id
        self.url = url
        self.maximumAllowedBytes = maximumAllowedBytes
        self.allowedSchemes = normalizedSchemes
    }

    public var redactedURL: RedactedDownloadURL {
        RedactedDownloadURL(url: url)
    }

    public var description: String {
        "DownloadRequest(id: \(id), url: \(redactedURL))"
    }
}
