import Foundation

/// Product-independent deployment environment category.
///
/// The package intentionally does not define product-specific values such as
/// `newsDev`, `clientAProduction`, or project route names.
public enum EnvironmentKind: Equatable, Hashable, Sendable, Codable {
    case development
    case staging
    case production
    case custom(String)

    public init(rawValue: String?) {
        let normalized: String?
        if let rawValue {
            let value = EnvironmentKind.normalized(rawValue)
            normalized = value.isEmpty ? nil : value
        } else {
            normalized = nil
        }

        switch normalized {
        case nil:
            self = .production
        case "dev", "development", "debug", "local":
            self = .development
        case "stage", "staging", "qa", "test", "testing":
            self = .staging
        case "prod", "production", "release", "live":
            self = .production
        case let value?:
            self = .custom(value)
        }
    }

    public var stableCode: String {
        switch self {
        case .development:
            return "development"
        case .staging:
            return "staging"
        case .production:
            return "production"
        case .custom(let value):
            return "custom.\(EnvironmentKind.normalized(value))"
        }
    }

    private static func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
    }
}

extension EnvironmentKind: CustomStringConvertible {
    public var description: String { stableCode }
}
