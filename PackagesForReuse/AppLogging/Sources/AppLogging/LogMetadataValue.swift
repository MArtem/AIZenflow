import Foundation

/// Primitive value that can be attached to a log event without coupling logging to app-specific models.
public enum LogMetadataValue: Codable, Equatable, Sendable {
    case string(String, privacy: LogPrivacy = .public)
    case integer(Int, privacy: LogPrivacy = .public)
    case double(Double, privacy: LogPrivacy = .public)
    case bool(Bool, privacy: LogPrivacy = .public)
    case date(Date, privacy: LogPrivacy = .public)
    case url(String, privacy: LogPrivacy = .public)
    case stringArray([String], privacy: LogPrivacy = .public)
    case null

    public var privacy: LogPrivacy {
        switch self {
        case .string(_, let privacy),
             .integer(_, let privacy),
             .double(_, let privacy),
             .bool(_, let privacy),
             .date(_, let privacy),
             .url(_, let privacy),
             .stringArray(_, let privacy):
            privacy
        case .null:
            .public
        }
    }

    public func redactedDescription(key: String, redactor: LogRedactor = .default) -> String {
        if !privacy.isPublic {
            return privacy.replacement
        }
        if redactor.shouldRedactKey(key) {
            return "<redacted>"
        }

        switch self {
        case .string(let value, _):
            return redactor.redactString(value)
        case .integer(let value, _):
            return String(value)
        case .double(let value, _):
            return String(value)
        case .bool(let value, _):
            return String(value)
        case .date(let value, _):
            return AppLoggingDateFormatter.string(from: value)
        case .url(let value, _):
            return redactor.redactURLString(value)
        case .stringArray(let values, _):
            let safeValues = values.map { redactor.redactString($0) }
            return "[" + safeValues.joined(separator: ", ") + "]"
        case .null:
            return "null"
        }
    }
}
