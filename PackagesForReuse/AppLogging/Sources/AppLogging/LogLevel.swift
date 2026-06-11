import Foundation

/// Severity of a log event.
public enum LogLevel: Int, Codable, CaseIterable, Comparable, Sendable {
    case trace = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case critical = 5

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var name: String {
        switch self {
        case .trace: "trace"
        case .debug: "debug"
        case .info: "info"
        case .warning: "warning"
        case .error: "error"
        case .critical: "critical"
        }
    }
}
