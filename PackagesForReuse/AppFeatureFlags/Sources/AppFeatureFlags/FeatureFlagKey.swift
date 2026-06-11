import Foundation

/// A stable, app-independent identifier for a feature flag.
///
/// The key intentionally carries no product semantics. Apps may define keys in their own
/// layer through extensions or constants.
public struct FeatureFlagKey: RawRepresentable, Hashable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }

    public init(namespace: String, name: String) {
        let cleanNamespace = namespace.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanNamespace.isEmpty {
            self.init(rawValue: cleanName)
        } else {
            self.init(rawValue: "\(cleanNamespace).\(cleanName)")
        }
    }

    public var isEmpty: Bool { rawValue.isEmpty }

    public var description: String { rawValue }
}
