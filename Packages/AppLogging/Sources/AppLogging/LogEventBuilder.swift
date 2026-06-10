import Foundation

/// Small value builder that helps construct structured events without app-specific coupling.
public struct LogEventBuilder: Sendable {
    private var level: LogLevel
    private var subsystem: String
    private var category: String
    private var message: String
    private var messagePrivacy: LogPrivacy
    private var metadata: LogMetadata
    private var source: LogSourceLocation?

    public init(level: LogLevel, message: String) {
        self.level = level
        self.subsystem = "app"
        self.category = "general"
        self.message = message
        self.messagePrivacy = .public
        self.metadata = LogMetadata()
    }

    public func subsystem(_ value: String) -> LogEventBuilder {
        var copy = self
        copy.subsystem = value
        return copy
    }

    public func category(_ value: String) -> LogEventBuilder {
        var copy = self
        copy.category = value
        return copy
    }

    public func messagePrivacy(_ value: LogPrivacy) -> LogEventBuilder {
        var copy = self
        copy.messagePrivacy = value
        return copy
    }

    public func metadata(_ key: String, _ value: LogMetadataValue) -> LogEventBuilder {
        var copy = self
        copy.metadata[key] = value
        return copy
    }

    public func source(file: String = #fileID, function: String = #function, line: Int = #line) -> LogEventBuilder {
        var copy = self
        copy.source = LogSourceLocation(file: file, function: function, line: line)
        return copy
    }

    public func build(timestamp: Date = Date(), id: UUID = UUID()) -> LogEvent {
        LogEvent(
            id: id,
            timestamp: timestamp,
            level: level,
            subsystem: subsystem,
            category: category,
            message: message,
            messagePrivacy: messagePrivacy,
            metadata: metadata,
            source: source
        )
    }
}
