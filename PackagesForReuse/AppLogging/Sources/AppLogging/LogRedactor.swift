import Foundation

/// Privacy guard used before text is emitted to console, OSLog, files, or remote adapters.
public struct LogRedactor: Sendable, Equatable {
    public var sensitiveKeys: Set<String>
    public var stringMasks: [String: String]
    public var stripsURLQueryAndFragment: Bool

    public init(
        sensitiveKeys: Set<String> = LogRedactor.defaultSensitiveKeys,
        stringMasks: [String: String] = [:],
        stripsURLQueryAndFragment: Bool = true
    ) {
        self.sensitiveKeys = Set(sensitiveKeys.map { $0.lowercased() })
        self.stringMasks = stringMasks
        self.stripsURLQueryAndFragment = stripsURLQueryAndFragment
    }

    public static let defaultSensitiveKeys: Set<String> = [
        "token", "access_token", "refresh_token", "authorization", "auth", "password",
        "secret", "cookie", "set-cookie", "session", "api_key", "apikey", "client_secret"
    ]

    public static let `default` = LogRedactor()

    public func shouldRedactKey(_ key: String) -> Bool {
        let normalized = key.lowercased()
        if sensitiveKeys.contains(normalized) { return true }
        return sensitiveKeys.contains { sensitive in normalized.contains(sensitive) }
    }

    public func redactString(_ value: String) -> String {
        var result = value
        for (needle, replacement) in stringMasks where !needle.isEmpty {
            result = result.replacingOccurrences(of: needle, with: replacement)
        }
        return result
    }

    public func redactURLString(_ value: String) -> String {
        guard stripsURLQueryAndFragment, var components = URLComponents(string: value) else {
            return redactString(value)
        }
        components.query = nil
        components.fragment = nil
        return redactString(components.string ?? value)
    }
}
