import Foundation

/// A structured, app-independent log event.
public struct LogEvent: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let level: LogLevel
    public let subsystem: String
    public let category: String
    public let message: String
    public let messagePrivacy: LogPrivacy
    public let metadata: LogMetadata
    public let source: LogSourceLocation?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        level: LogLevel,
        subsystem: String = "app",
        category: String = "general",
        message: String,
        messagePrivacy: LogPrivacy = .public,
        metadata: LogMetadata = LogMetadata(),
        source: LogSourceLocation? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.subsystem = subsystem
        self.category = category
        self.message = message
        self.messagePrivacy = messagePrivacy
        self.metadata = metadata
        self.source = source
    }
}

public struct LogSourceLocation: Codable, Equatable, Sendable {
    public let file: String
    public let function: String
    public let line: Int

    public init(file: String, function: String, line: Int) {
        self.file = file
        self.function = function
        self.line = line
    }
}
