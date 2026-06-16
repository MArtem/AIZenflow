public struct RateLimitRequest: Hashable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let key: RateLimitKey
    public let policy: RateLimitPolicy
    public let cost: RateLimitCost

    public init(
        key: RateLimitKey,
        policy: RateLimitPolicy,
        cost: RateLimitCost
    ) {
        self.key = key
        self.policy = policy
        self.cost = cost
    }

    public var description: String {
        "RateLimitRequest(key:\(key),cost:\(cost.units),policy:\(policyKind))"
    }

    public var debugDescription: String {
        description
    }

    private var policyKind: String {
        switch policy {
        case .fixedWindow:
            return "fixedWindow"
        case .slidingWindow:
            return "slidingWindow"
        case .tokenBucket:
            return "tokenBucket"
        }
    }
}
