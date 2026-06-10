import Foundation

/// Stable identifier for a value stored in secure storage.
///
/// `SecureStorageKey` is intentionally product-neutral. Application-specific keys
/// should be defined by the host app in extensions, for example:
///
/// ```swift
/// extension SecureStorageKey {
///     static let accessToken = SecureStorageKey("auth.access-token")
/// }
/// ```
public struct SecureStorageKey: RawRepresentable, Hashable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }

    /// A redacted description suitable for logs and diagnostics.
    ///
    /// This intentionally does not include a stable hash. Many secure-storage keys
    /// are low-entropy and guessable (`auth.access-token`, `refreshToken`, etc.), so
    /// a deterministic hash can still leak useful information to logs/telemetry.
    public var description: String {
        "SecureStorageKey(<redacted>)"
    }
}

/// Optional namespace used by callers to group keys without leaking product
/// concepts into the package itself.
public struct SecureStorageNamespace: RawRepresentable, Hashable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }

    public func key(_ localKey: SecureStorageKey) -> SecureStorageKey {
        SecureStorageKey("\(rawValue).\(localKey.rawValue)")
    }

    /// A redacted description suitable for logs and diagnostics.
    public var description: String {
        "SecureStorageNamespace(<redacted>)"
    }
}
