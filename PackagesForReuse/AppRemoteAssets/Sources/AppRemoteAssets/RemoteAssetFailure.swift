import Foundation

public struct RemoteAssetFailure: Error, Equatable, Sendable, CustomStringConvertible {
    public enum Code: String, Equatable, Sendable, Codable {
        case emptyIdentifier
        case identifierTooLong
        case unsafeIdentifier
        case emptyVersion
        case versionTooLong
        case unsafeVersion
        case unsupportedURLScheme
        case invalidManifest
        case duplicateAssetIdentifier
        case responseTooLarge
        case unacceptableStatusCode
        case decodingFailed
        case transportFailed
        case invalidCachePolicy
        case invalidByteCount
        case unsafeMediaType
    }

    public let code: Code
    public let context: String

    public init(code: Code, context: String = "redacted") {
        self.code = code
        self.context = Self.sanitizedContext(context)
    }

    public var description: String {
        "RemoteAssetFailure(code: \(code.rawValue), context: \(context))"
    }

    private static func sanitizedContext(_ context: String) -> String {
        let trimmed = context.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "redacted" }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")
        guard trimmed.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            return "redacted"
        }
        return String(trimmed.prefix(64))
    }
}
