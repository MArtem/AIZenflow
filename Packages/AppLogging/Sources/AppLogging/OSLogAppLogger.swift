#if canImport(os)
import Foundation
import os

/// Apple OSLog adapter.
///
/// This type is intentionally standalone and does not depend on analytics, observability,
/// crash reporting, networking, or app-specific domains.
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct OSLogAppLogger: AppLogging {
    private let logger: os.Logger
    private let minimumLevel: LogLevel
    private let redactor: LogRedactor
    private let formatter: any LogFormatting

    public init(
        subsystem: String,
        category: String,
        minimumLevel: LogLevel = .debug,
        redactor: LogRedactor = .default,
        formatter: any LogFormatting = DefaultLogFormatter()
    ) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
        self.minimumLevel = minimumLevel
        self.redactor = redactor
        self.formatter = formatter
    }

    public func log(_ event: LogEvent) async {
        guard event.level >= minimumLevel else { return }
        let rendered = formatter.format(event, redactor: redactor)
        switch event.level {
        case .trace, .debug:
            logger.debug("\(rendered, privacy: .public)")
        case .info:
            logger.info("\(rendered, privacy: .public)")
        case .warning:
            logger.warning("\(rendered, privacy: .public)")
        case .error:
            logger.error("\(rendered, privacy: .public)")
        case .critical:
            logger.critical("\(rendered, privacy: .public)")
        }
    }
}
#endif
