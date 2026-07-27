import Foundation

public struct RedactedDownloadURL: Equatable, Sendable, Codable, CustomStringConvertible {
    public let scheme: String?
    public let host: String?
    public let pathExtension: String?

    public init(url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil
        components?.fragment = nil
        self.scheme = components?.scheme
        self.host = components?.host
        let cleanURL = components?.url ?? url
        let fileExtension = cleanURL.pathExtension
        self.pathExtension = fileExtension.isEmpty ? nil : fileExtension
    }

    public var description: String {
        let schemePart = scheme ?? "unknown"
        let hostPart = host.map { _ in "present" } ?? "absent"
        let extensionPart = pathExtension.map { _ in "present" } ?? "absent"
        return "RedactedDownloadURL(scheme: \(schemePart), host: \(hostPart), extension: \(extensionPart))"
    }
}
