import Foundation

public protocol AppTaskQueueClock: Sendable {
    func now() -> Date
}

public struct SystemAppTaskQueueClock: AppTaskQueueClock {
    public init() {}

    public func now() -> Date {
        Date()
    }
}

public struct FixedAppTaskQueueClock: AppTaskQueueClock {
    private let fixedDate: Date

    public init(_ fixedDate: Date) {
        self.fixedDate = fixedDate
    }

    public func now() -> Date {
        fixedDate
    }
}
