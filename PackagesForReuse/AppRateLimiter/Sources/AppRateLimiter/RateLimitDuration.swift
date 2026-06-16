public struct RateLimitDuration: Hashable, Comparable, Codable, Sendable {
    public let milliseconds: Int64

    public init(milliseconds: Int64) throws {
        guard milliseconds > 0 else {
            throw RateLimitFailure.invalidDuration
        }
        self.milliseconds = milliseconds
    }

    public static func milliseconds(_ value: Int64) throws -> RateLimitDuration {
        try RateLimitDuration(milliseconds: value)
    }

    public static func seconds(_ value: Int64) throws -> RateLimitDuration {
        guard value > 0 else {
            throw RateLimitFailure.invalidDuration
        }
        let multiplied = value.multipliedReportingOverflow(by: 1_000)
        guard multiplied.overflow == false else {
            throw RateLimitFailure.invalidDuration
        }
        return try RateLimitDuration(milliseconds: multiplied.partialValue)
    }

    public static func minutes(_ value: Int64) throws -> RateLimitDuration {
        guard value > 0 else {
            throw RateLimitFailure.invalidDuration
        }
        let multiplied = value.multipliedReportingOverflow(by: 60_000)
        guard multiplied.overflow == false else {
            throw RateLimitFailure.invalidDuration
        }
        return try RateLimitDuration(milliseconds: multiplied.partialValue)
    }

    public static func < (lhs: RateLimitDuration, rhs: RateLimitDuration) -> Bool {
        lhs.milliseconds < rhs.milliseconds
    }

    public func multiplied(by factor: UInt64) -> RateLimitDuration {
        guard factor > 0 else {
            return self
        }
        let cappedFactor = factor > UInt64(Int64.max) ? Int64.max : Int64(factor)
        let multiplied = milliseconds.multipliedReportingOverflow(by: cappedFactor)
        if multiplied.overflow || multiplied.partialValue <= 0 {
            return RateLimitDuration.capped
        }
        return RateLimitDuration(checkedMilliseconds: multiplied.partialValue)
    }

    static let capped = RateLimitDuration(checkedMilliseconds: Int64.max)

    init(checkedMilliseconds: Int64) {
        self.milliseconds = max(1, checkedMilliseconds)
    }
}
