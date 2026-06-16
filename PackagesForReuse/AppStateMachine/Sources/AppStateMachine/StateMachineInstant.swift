import Foundation

public struct StateMachineInstant: Codable, Comparable, Hashable, Sendable {
    public let millisecondsSinceEpoch: Int64

    public init(millisecondsSinceEpoch: Int64) {
        self.millisecondsSinceEpoch = millisecondsSinceEpoch
    }

    public static func < (lhs: StateMachineInstant, rhs: StateMachineInstant) -> Bool {
        lhs.millisecondsSinceEpoch < rhs.millisecondsSinceEpoch
    }
}

public protocol StateMachineClock: Sendable {
    func now() async -> StateMachineInstant
}

public struct SystemStateMachineClock: StateMachineClock {
    public init() {}

    public func now() async -> StateMachineInstant {
        let milliseconds = Int64((Date().timeIntervalSince1970 * 1_000).rounded())
        return StateMachineInstant(millisecondsSinceEpoch: milliseconds)
    }
}

public actor ManualStateMachineClock: StateMachineClock {
    private var current: StateMachineInstant

    public init(start: StateMachineInstant = StateMachineInstant(millisecondsSinceEpoch: 0)) {
        self.current = start
    }

    public func now() async -> StateMachineInstant {
        current
    }

    public func advance(milliseconds: Int64) {
        let advanced = current.millisecondsSinceEpoch.addingReportingOverflow(milliseconds)
        if advanced.overflow {
            current = StateMachineInstant(millisecondsSinceEpoch: milliseconds >= 0 ? Int64.max : Int64.min)
        } else {
            current = StateMachineInstant(millisecondsSinceEpoch: advanced.partialValue)
        }
    }
}
