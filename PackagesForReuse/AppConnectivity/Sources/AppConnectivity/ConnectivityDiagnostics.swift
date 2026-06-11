import Foundation

/// A privacy-safe diagnostic representation of connectivity.
public struct ConnectivityDiagnosticSnapshot: Codable, Equatable, Sendable {
    public var status: ConnectivityStatus
    public var interfaces: [ConnectivityInterfaceKind]
    public var isExpensive: Bool
    public var isConstrained: Bool

    public init(snapshot: ConnectivitySnapshot) {
        self.status = snapshot.status
        self.interfaces = snapshot.interfaces.sorted()
        self.isExpensive = snapshot.isExpensive
        self.isConstrained = snapshot.isConstrained
    }
}

public extension ConnectivitySnapshot {
    var diagnosticSnapshot: ConnectivityDiagnosticSnapshot {
        ConnectivityDiagnosticSnapshot(snapshot: self)
    }
}
