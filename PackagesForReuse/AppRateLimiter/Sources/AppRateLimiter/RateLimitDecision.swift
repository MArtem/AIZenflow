public enum RateLimitDecision: Equatable, Sendable {
    case allowed(RateLimitGrant)
    case rejected(RateLimitRejection)

    public var isAllowed: Bool {
        switch self {
        case .allowed:
            return true
        case .rejected:
            return false
        }
    }

    public var remainingUnits: UInt64 {
        switch self {
        case .allowed(let grant):
            return grant.remainingUnits
        case .rejected(let rejection):
            return rejection.remainingUnits
        }
    }

    public var retryAfter: RateLimitDuration? {
        switch self {
        case .allowed:
            return nil
        case .rejected(let rejection):
            return rejection.retryAfter
        }
    }
}

public struct RateLimitGrant: Equatable, Sendable {
    public let remainingUnits: UInt64
    public let resetAfter: RateLimitDuration

    public init(remainingUnits: UInt64, resetAfter: RateLimitDuration) {
        self.remainingUnits = remainingUnits
        self.resetAfter = resetAfter
    }
}

public struct RateLimitRejection: Equatable, Sendable {
    public let remainingUnits: UInt64
    public let retryAfter: RateLimitDuration
    public let resetAfter: RateLimitDuration
    public let reason: RateLimitRejectionReason

    public init(
        remainingUnits: UInt64,
        retryAfter: RateLimitDuration,
        resetAfter: RateLimitDuration,
        reason: RateLimitRejectionReason = .rateLimited
    ) {
        self.remainingUnits = remainingUnits
        self.retryAfter = retryAfter
        self.resetAfter = resetAfter
        self.reason = reason
    }
}

public enum RateLimitRejectionReason: String, Codable, Equatable, Sendable {
    case rateLimited
    case costExceedsLimit
}
