public enum RateLimitPolicy: Hashable, Codable, Sendable {
    case fixedWindow(limit: RateLimitLimit, interval: RateLimitDuration)
    case slidingWindow(limit: RateLimitLimit, interval: RateLimitDuration)
    case tokenBucket(capacity: RateLimitLimit, refillAmount: RateLimitLimit, refillInterval: RateLimitDuration)

    public static func makeTokenBucket(
        capacity: RateLimitLimit,
        refillAmount: RateLimitLimit,
        refillInterval: RateLimitDuration
    ) throws -> RateLimitPolicy {
        guard refillAmount.units <= capacity.units else {
            throw RateLimitFailure.refillAmountExceedsCapacity
        }
        return .tokenBucket(capacity: capacity, refillAmount: refillAmount, refillInterval: refillInterval)
    }

    public var maximumUnits: UInt64 {
        switch self {
        case .fixedWindow(let limit, _), .slidingWindow(let limit, _):
            return limit.units
        case .tokenBucket(let capacity, _, _):
            return capacity.units
        }
    }

    public var windowInterval: RateLimitDuration {
        switch self {
        case .fixedWindow(_, let interval), .slidingWindow(_, let interval):
            return interval
        case .tokenBucket(_, _, let refillInterval):
            return refillInterval
        }
    }
}
