public enum RateLimitFailure: Error, Equatable, Sendable {
    case emptyKey
    case keyTooLong(maximumLength: Int)
    case unsafeKeyCharacter
    case invalidLimit
    case invalidCost
    case invalidDuration
    case refillAmountExceedsCapacity
}
