import Foundation

public struct ObservabilityRedactor: Sendable {
    public let sensitiveKeys: Set<String>
    public let sensitiveReplacement: String

    public init(
        sensitiveKeys: Set<String> = ObservabilityRedactor.defaultSensitiveKeys,
        sensitiveReplacement: String = "<redacted>"
    ) {
        self.sensitiveKeys = Set(sensitiveKeys.map { $0.lowercased() })
        self.sensitiveReplacement = sensitiveReplacement
    }

    public static let defaultSensitiveKeys: Set<String> = [
        "token",
        "access_token",
        "refresh_token",
        "authorization",
        "cookie",
        "set-cookie",
        "password",
        "secret",
        "api_key",
        "apikey",
        "session",
        "session_id",
        "email",
        "phone"
    ]

    public func redact(_ attributes: ObservabilityAttributes) -> ObservabilityAttributes {
        attributes.reduce(into: ObservabilityAttributes()) { partialResult, pair in
            partialResult[pair.key] = redact(attribute: pair.value, forKey: pair.key)
        }
    }

    public func redact(attribute: ObservabilityAttribute, forKey key: String) -> ObservabilityAttribute {
        if attribute.privacy != .public || sensitiveKeys.contains(key.lowercased()) {
            return .string(sensitiveReplacement, privacy: .private)
        }

        switch attribute.value {
        case .string(let string):
            return .string(redactURLLikeStringIfNeeded(string), privacy: attribute.privacy)
        default:
            return attribute
        }
    }

    public func redactURLLikeStringIfNeeded(_ string: String) -> String {
        guard shouldAttemptURLRedaction(for: string), var components = URLComponents(string: string) else {
            return string
        }

        guard components.query != nil || components.fragment != nil else {
            return string
        }

        components.query = nil
        components.fragment = nil
        return components.string ?? string
    }

    private func shouldAttemptURLRedaction(for string: String) -> Bool {
        guard string.contains("?") || string.contains("#") else {
            return false
        }

        guard string.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else {
            return false
        }

        let candidate = string.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first?
            .split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false).first
            ?? Substring()
        let base = String(candidate)

        if string.hasPrefix("//") || string.hasPrefix("/") || string.contains("://") {
            return true
        }

        if base.contains("/") {
            return true
        }

        let allowedScalars = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~%")
        return !base.isEmpty && base.unicodeScalars.allSatisfy(allowedScalars.contains)
    }
}
