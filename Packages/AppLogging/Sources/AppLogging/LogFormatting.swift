import Foundation

public protocol LogFormatting: Sendable {
    func format(_ event: LogEvent, redactor: LogRedactor) -> String
}

public struct DefaultLogFormatter: LogFormatting, Sendable {
    public init() {}

    public func format(_ event: LogEvent, redactor: LogRedactor = .default) -> String {
        let timestamp = AppLoggingDateFormatter.string(from: event.timestamp)
        let metadata = event.metadata.redacted(redactor: redactor)
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        let suffix = metadata.isEmpty ? "" : " \(metadata)"
        let message = event.messagePrivacy.isPublic ? redactor.redactString(event.message) : event.messagePrivacy.replacement
        return "\(timestamp) [\(event.level.name.uppercased())] \(event.subsystem).\(event.category): \(message)\(suffix)"
    }
}
