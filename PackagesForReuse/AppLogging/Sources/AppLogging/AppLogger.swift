import Foundation

/// Minimal logging contract used by apps and other packages through optional integrations.
public protocol AppLogging: Sendable {
    func log(_ event: LogEvent) async
}

public extension AppLogging {
    func trace(_ message: String, subsystem: String = "app", category: String = "general", messagePrivacy: LogPrivacy = .public, metadata: LogMetadata = LogMetadata()) async {
        await log(LogEvent(level: .trace, subsystem: subsystem, category: category, message: message, messagePrivacy: messagePrivacy, metadata: metadata))
    }

    func debug(_ message: String, subsystem: String = "app", category: String = "general", messagePrivacy: LogPrivacy = .public, metadata: LogMetadata = LogMetadata()) async {
        await log(LogEvent(level: .debug, subsystem: subsystem, category: category, message: message, messagePrivacy: messagePrivacy, metadata: metadata))
    }

    func info(_ message: String, subsystem: String = "app", category: String = "general", messagePrivacy: LogPrivacy = .public, metadata: LogMetadata = LogMetadata()) async {
        await log(LogEvent(level: .info, subsystem: subsystem, category: category, message: message, messagePrivacy: messagePrivacy, metadata: metadata))
    }

    func warning(_ message: String, subsystem: String = "app", category: String = "general", messagePrivacy: LogPrivacy = .public, metadata: LogMetadata = LogMetadata()) async {
        await log(LogEvent(level: .warning, subsystem: subsystem, category: category, message: message, messagePrivacy: messagePrivacy, metadata: metadata))
    }

    func error(_ message: String, subsystem: String = "app", category: String = "general", messagePrivacy: LogPrivacy = .public, metadata: LogMetadata = LogMetadata()) async {
        await log(LogEvent(level: .error, subsystem: subsystem, category: category, message: message, messagePrivacy: messagePrivacy, metadata: metadata))
    }

    func critical(_ message: String, subsystem: String = "app", category: String = "general", messagePrivacy: LogPrivacy = .public, metadata: LogMetadata = LogMetadata()) async {
        await log(LogEvent(level: .critical, subsystem: subsystem, category: category, message: message, messagePrivacy: messagePrivacy, metadata: metadata))
    }
}

public struct AnyAppLogger: AppLogging {
    private let _log: @Sendable (LogEvent) async -> Void

    public init(_ log: @escaping @Sendable (LogEvent) async -> Void) {
        self._log = log
    }

    public init<L: AppLogging>(_ logger: L) {
        self._log = { event in await logger.log(event) }
    }

    public func log(_ event: LogEvent) async {
        await _log(event)
    }
}
