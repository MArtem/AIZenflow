public actor AppRateLimiter {
    private let store: any RateLimitStore
    private let clock: any RateLimitClock

    public init(
        store: any RateLimitStore = InMemoryRateLimitStore(),
        clock: any RateLimitClock = SystemRateLimitClock()
    ) {
        self.store = store
        self.clock = clock
    }

    public func evaluate(_ request: RateLimitRequest) async throws -> RateLimitDecision {
        let instant = await clock.now()
        return try await store.evaluate(request, at: instant)
    }

    public func reset(key: RateLimitKey) async throws {
        try await store.reset(key: key)
    }

    public func resetAll() async throws {
        try await store.resetAll()
    }
}
