public struct RateLimitInstant: Hashable, Comparable, Codable, Sendable {
    public let millisecondsSinceReference: Int64

    public init(millisecondsSinceReference: Int64) {
        self.millisecondsSinceReference = millisecondsSinceReference
    }

    public static func < (lhs: RateLimitInstant, rhs: RateLimitInstant) -> Bool {
        lhs.millisecondsSinceReference < rhs.millisecondsSinceReference
    }

    public func advanced(by duration: RateLimitDuration) -> RateLimitInstant {
        let added = millisecondsSinceReference.addingReportingOverflow(duration.milliseconds)
        if added.overflow {
            return RateLimitInstant(millisecondsSinceReference: Int64.max)
        }
        return RateLimitInstant(millisecondsSinceReference: added.partialValue)
    }

    public func elapsedMilliseconds(since earlier: RateLimitInstant) -> Int64 {
        let difference = millisecondsSinceReference.subtractingReportingOverflow(earlier.millisecondsSinceReference)
        if difference.overflow || difference.partialValue < 0 {
            return 0
        }
        return difference.partialValue
    }
}
