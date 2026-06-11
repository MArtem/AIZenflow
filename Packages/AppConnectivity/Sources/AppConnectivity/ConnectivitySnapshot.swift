import Foundation

/// A point-in-time view of current connectivity.
public struct ConnectivitySnapshot: Codable, Equatable, Sendable {
    public var status: ConnectivityStatus
    public var interfaces: Set<ConnectivityInterfaceKind>
    public var isExpensive: Bool
    public var isConstrained: Bool
    public var timestamp: Date

    public init(
        status: ConnectivityStatus,
        interfaces: Set<ConnectivityInterfaceKind> = [],
        isExpensive: Bool = false,
        isConstrained: Bool = false,
        timestamp: Date = Date()
    ) {
        self.status = status
        self.interfaces = interfaces
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
        self.timestamp = timestamp
    }

    public var isOnline: Bool {
        status == .online
    }

    public var primaryInterface: ConnectivityInterfaceKind {
        interfaces.sorted().first ?? .unknown
    }

    public func isAllowed(by policy: ConnectivityCostPolicy) -> Bool {
        guard status.isUsable else { return false }
        if isExpensive && !policy.allowsExpensiveConnections { return false }
        if isConstrained && !policy.allowsConstrainedConnections { return false }
        return true
    }

    public static func unknown(timestamp: Date = Date()) -> ConnectivitySnapshot {
        ConnectivitySnapshot(status: .unknown, interfaces: [.unknown], timestamp: timestamp)
    }

    public static func online(
        interfaces: Set<ConnectivityInterfaceKind> = [.wifi],
        isExpensive: Bool = false,
        isConstrained: Bool = false,
        timestamp: Date = Date()
    ) -> ConnectivitySnapshot {
        ConnectivitySnapshot(
            status: .online,
            interfaces: interfaces,
            isExpensive: isExpensive,
            isConstrained: isConstrained,
            timestamp: timestamp
        )
    }

    public static func offline(timestamp: Date = Date()) -> ConnectivitySnapshot {
        ConnectivitySnapshot(status: .offline, interfaces: [], timestamp: timestamp)
    }
}

/// A transition from one connectivity snapshot to another.
public struct ConnectivityChange: Equatable, Sendable {
    public var previous: ConnectivitySnapshot?
    public var current: ConnectivitySnapshot

    public init(previous: ConnectivitySnapshot?, current: ConnectivitySnapshot) {
        self.previous = previous
        self.current = current
    }

    public var becameOnline: Bool {
        previous?.isOnline != true && current.isOnline
    }

    public var becameOffline: Bool {
        previous?.isOnline == true && !current.isOnline
    }

    public var costChanged: Bool {
        guard let previous else { return false }
        return previous.isExpensive != current.isExpensive || previous.isConstrained != current.isConstrained
    }
}
