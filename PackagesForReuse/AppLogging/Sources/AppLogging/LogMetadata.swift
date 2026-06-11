import Foundation

/// Key/value metadata attached to a log event.
public struct LogMetadata: Codable, Equatable, Sendable {
    public var values: [String: LogMetadataValue]

    public init(_ values: [String: LogMetadataValue] = [:]) {
        self.values = values
    }

    public subscript(_ key: String) -> LogMetadataValue? {
        get { values[key] }
        set { values[key] = newValue }
    }

    public var isEmpty: Bool { values.isEmpty }

    public func merging(_ other: LogMetadata) -> LogMetadata {
        LogMetadata(values.merging(other.values, uniquingKeysWith: { _, new in new }))
    }

    public func redacted(redactor: LogRedactor = .default) -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in values {
            result[key] = value.redactedDescription(key: key, redactor: redactor)
        }
        return result
    }
}
