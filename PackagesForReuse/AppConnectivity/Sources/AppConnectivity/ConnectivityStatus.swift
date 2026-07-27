import Foundation

/// Describes the high-level availability of the network.
public enum ConnectivityStatus: String, Codable, CaseIterable, Sendable {
    /// The current status has not been determined yet.
    case unknown

    /// Network is available and can be used.
    case online

    /// Network is currently unavailable.
    case offline

    /// The system may establish a connection on demand.
    case requiresConnection

    /// Convenience flag for deciding whether network-dependent work may start now.
    public var isUsable: Bool {
        switch self {
        case .online:
            return true
        case .unknown, .offline, .requiresConnection:
            return false
        }
    }
}

/// A normalized network interface kind.
public enum ConnectivityInterfaceKind: String, Codable, CaseIterable, Sendable, Comparable {
    case wifi
    case cellular
    case wiredEthernet
    case loopback
    case other
    case unknown

    public static func < (lhs: ConnectivityInterfaceKind, rhs: ConnectivityInterfaceKind) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// A user/app-level policy for network cost constraints.
public struct ConnectivityCostPolicy: Codable, Equatable, Sendable {
    /// Whether work is allowed on expensive connections, such as cellular or hotspot.
    public var allowsExpensiveConnections: Bool

    /// Whether work is allowed while the system marks the connection as constrained, e.g. Low Data Mode.
    public var allowsConstrainedConnections: Bool

    public init(
        allowsExpensiveConnections: Bool = true,
        allowsConstrainedConnections: Bool = true
    ) {
        self.allowsExpensiveConnections = allowsExpensiveConnections
        self.allowsConstrainedConnections = allowsConstrainedConnections
    }

    /// Default policy for user-visible lightweight operations.
    public static let permissive = ConnectivityCostPolicy()

    /// Useful for large downloads, uploads, or background sync.
    public static let conservative = ConnectivityCostPolicy(
        allowsExpensiveConnections: false,
        allowsConstrainedConnections: false
    )
}
