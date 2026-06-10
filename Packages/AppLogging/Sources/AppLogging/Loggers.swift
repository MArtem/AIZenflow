import Foundation

public struct NoopLogger: AppLogging {
    public init() {}
    public func log(_ event: LogEvent) async {}
}

public actor MemoryLogger: AppLogging {
    private var storage: [LogEvent] = []
    private let minimumLevel: LogLevel

    public init(minimumLevel: LogLevel = .trace) {
        self.minimumLevel = minimumLevel
    }

    public func log(_ event: LogEvent) async {
        guard event.level >= minimumLevel else { return }
        storage.append(event)
    }

    public func events() -> [LogEvent] {
        storage
    }

    public func clear() {
        storage.removeAll()
    }
}

public struct ConsoleLogger: AppLogging {
    private let minimumLevel: LogLevel
    private let redactor: LogRedactor
    private let formatter: any LogFormatting
    private let output: @Sendable (String) -> Void

    public init(
        minimumLevel: LogLevel = .debug,
        redactor: LogRedactor = .default,
        formatter: any LogFormatting = DefaultLogFormatter(),
        output: @escaping @Sendable (String) -> Void = { Swift.print($0) }
    ) {
        self.minimumLevel = minimumLevel
        self.redactor = redactor
        self.formatter = formatter
        self.output = output
    }

    public func log(_ event: LogEvent) async {
        guard event.level >= minimumLevel else { return }
        output(formatter.format(event, redactor: redactor))
    }
}

public struct RedactingLogger<Base: AppLogging>: AppLogging {
    private let base: Base
    private let redactor: LogRedactor

    public init(base: Base, redactor: LogRedactor = .default) {
        self.base = base
        self.redactor = redactor
    }

    public func log(_ event: LogEvent) async {
        let redactedValues = event.metadata.redacted(redactor: redactor).mapValues { LogMetadataValue.string($0) }
        let redactedEvent = LogEvent(
            id: event.id,
            timestamp: event.timestamp,
            level: event.level,
            subsystem: event.subsystem,
            category: event.category,
            message: event.messagePrivacy.isPublic ? redactor.redactString(event.message) : event.messagePrivacy.replacement,
            messagePrivacy: .public,
            metadata: LogMetadata(redactedValues),
            source: event.source
        )
        await base.log(redactedEvent)
    }
}

public struct MultiplexLogger: AppLogging {
    private let loggers: [AnyAppLogger]

    public init(_ loggers: [AnyAppLogger]) {
        self.loggers = loggers
    }

    public init<L1: AppLogging, L2: AppLogging>(_ first: L1, _ second: L2) {
        self.loggers = [AnyAppLogger(first), AnyAppLogger(second)]
    }

    public func log(_ event: LogEvent) async {
        for logger in loggers {
            await logger.log(event)
        }
    }
}
