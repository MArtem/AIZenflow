import Foundation

public protocol ObservabilityClock: Sendable {
    func now() -> Date
}

public struct SystemObservabilityClock: ObservabilityClock {
    public init() {}
    public func now() -> Date { Date() }
}
