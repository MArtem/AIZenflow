import Foundation

public protocol RateLimitClock: Sendable {
    func now() async -> RateLimitInstant
}

public struct SystemRateLimitClock: RateLimitClock {
    public init() {}

    public func now() async -> RateLimitInstant {
        let seconds = Date().timeIntervalSince1970
        let milliseconds = seconds * 1_000
        if milliseconds >= Double(Int64.max) {
            return RateLimitInstant(millisecondsSinceReference: Int64.max)
        }
        if milliseconds <= Double(Int64.min) {
            return RateLimitInstant(millisecondsSinceReference: Int64.min)
        }
        return RateLimitInstant(millisecondsSinceReference: Int64(milliseconds))
    }
}

public actor ManualRateLimitClock: RateLimitClock {
    private var current: RateLimitInstant

    public init(start: RateLimitInstant = RateLimitInstant(millisecondsSinceReference: 0)) {
        self.current = start
    }

    public func now() async -> RateLimitInstant {
        current
    }

    public func advance(by duration: RateLimitDuration) {
        current = current.advanced(by: duration)
    }
}
