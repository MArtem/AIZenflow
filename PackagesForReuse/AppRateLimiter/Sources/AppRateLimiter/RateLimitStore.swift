public protocol RateLimitStore: Sendable {
    func evaluate(_ request: RateLimitRequest, at instant: RateLimitInstant) async throws -> RateLimitDecision
    func reset(key: RateLimitKey) async throws
    func resetAll() async throws
}
