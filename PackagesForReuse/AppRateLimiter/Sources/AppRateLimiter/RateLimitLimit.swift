public struct RateLimitLimit: Hashable, Codable, Sendable, Comparable {
    public let units: UInt64

    public init(_ units: UInt64) throws {
        guard units > 0 else {
            throw RateLimitFailure.invalidLimit
        }
        self.units = units
    }

    public static func < (lhs: RateLimitLimit, rhs: RateLimitLimit) -> Bool {
        lhs.units < rhs.units
    }
}

public struct RateLimitCost: Hashable, Codable, Sendable, Comparable {
    public let units: UInt64

    public init(_ units: UInt64) throws {
        guard units > 0 else {
            throw RateLimitFailure.invalidCost
        }
        self.units = units
    }

    public static func < (lhs: RateLimitCost, rhs: RateLimitCost) -> Bool {
        lhs.units < rhs.units
    }
}
