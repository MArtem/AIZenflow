public actor InMemoryRateLimitStore: RateLimitStore {
    private struct StorageKey: Hashable, Sendable {
        let key: RateLimitKey
        let policy: RateLimitPolicy
    }

    private struct FixedWindowState: Sendable {
        var windowStart: RateLimitInstant
        var usedUnits: UInt64
    }

    private struct SlidingWindowEntry: Sendable {
        let instant: RateLimitInstant
        let costUnits: UInt64
    }

    private struct TokenBucketState: Sendable {
        var availableUnits: UInt64
        var lastRefill: RateLimitInstant
    }

    private var fixedWindows: [StorageKey: FixedWindowState]
    private var slidingWindows: [StorageKey: [SlidingWindowEntry]]
    private var tokenBuckets: [StorageKey: TokenBucketState]

    public init() {
        self.fixedWindows = [:]
        self.slidingWindows = [:]
        self.tokenBuckets = [:]
    }

    public func evaluate(_ request: RateLimitRequest, at instant: RateLimitInstant) async throws -> RateLimitDecision {
        switch request.policy {
        case .fixedWindow(let limit, let interval):
            return evaluateFixedWindow(request: request, limit: limit, interval: interval, instant: instant)
        case .slidingWindow(let limit, let interval):
            return evaluateSlidingWindow(request: request, limit: limit, interval: interval, instant: instant)
        case .tokenBucket(let capacity, let refillAmount, let refillInterval):
            return evaluateTokenBucket(
                request: request,
                capacity: capacity,
                refillAmount: refillAmount,
                refillInterval: refillInterval,
                instant: instant
            )
        }
    }

    public func reset(key: RateLimitKey) async throws {
        fixedWindows = fixedWindows.filter { $0.key.key != key }
        slidingWindows = slidingWindows.filter { $0.key.key != key }
        tokenBuckets = tokenBuckets.filter { $0.key.key != key }
    }

    public func resetAll() async throws {
        fixedWindows.removeAll()
        slidingWindows.removeAll()
        tokenBuckets.removeAll()
    }

    private func evaluateFixedWindow(
        request: RateLimitRequest,
        limit: RateLimitLimit,
        interval: RateLimitDuration,
        instant: RateLimitInstant
    ) -> RateLimitDecision {
        let storageKey = StorageKey(key: request.key, policy: request.policy)
        var state = fixedWindows[storageKey] ?? FixedWindowState(windowStart: instant, usedUnits: 0)
        let elapsed = instant.elapsedMilliseconds(since: state.windowStart)
        if elapsed >= interval.milliseconds {
            state = FixedWindowState(windowStart: instant, usedUnits: 0)
        }

        let resetAfter = remainingDuration(interval: interval, elapsedMilliseconds: instant.elapsedMilliseconds(since: state.windowStart))
        guard request.cost.units <= limit.units else {
            fixedWindows[storageKey] = state
            return .rejected(
                RateLimitRejection(
                    remainingUnits: 0,
                    retryAfter: resetAfter,
                    resetAfter: resetAfter,
                    reason: .costExceedsLimit
                )
            )
        }

        let requestedFixedUsage = state.usedUnits.saturatingSum(request.cost.units)
        if requestedFixedUsage <= limit.units {
            state.usedUnits = requestedFixedUsage
            fixedWindows[storageKey] = state
            return .allowed(
                RateLimitGrant(remainingUnits: limit.units - state.usedUnits, resetAfter: resetAfter)
            )
        }

        fixedWindows[storageKey] = state
        return .rejected(
            RateLimitRejection(remainingUnits: limit.units - state.usedUnits, retryAfter: resetAfter, resetAfter: resetAfter)
        )
    }

    private func evaluateSlidingWindow(
        request: RateLimitRequest,
        limit: RateLimitLimit,
        interval: RateLimitDuration,
        instant: RateLimitInstant
    ) -> RateLimitDecision {
        let storageKey = StorageKey(key: request.key, policy: request.policy)
        let retainedEntries = (slidingWindows[storageKey] ?? []).filter { entry in
            instant.elapsedMilliseconds(since: entry.instant) < interval.milliseconds
        }
        let usedUnits = retainedEntries.reduce(UInt64(0)) { partial, entry in
            partial.saturatingSum(entry.costUnits)
        }

        guard request.cost.units <= limit.units else {
            slidingWindows[storageKey] = retainedEntries
            return .rejected(
                RateLimitRejection(
                    remainingUnits: 0,
                    retryAfter: interval,
                    resetAfter: interval,
                    reason: .costExceedsLimit
                )
            )
        }

        let requestedSlidingUsage = usedUnits.saturatingSum(request.cost.units)
        if requestedSlidingUsage <= limit.units {
            var updatedEntries = retainedEntries
            updatedEntries.append(SlidingWindowEntry(instant: instant, costUnits: request.cost.units))
            slidingWindows[storageKey] = updatedEntries
            let resetAfter = updatedEntries.first.map { entry in
                remainingDuration(interval: interval, elapsedMilliseconds: instant.elapsedMilliseconds(since: entry.instant))
            } ?? interval
            return .allowed(
                RateLimitGrant(remainingUnits: limit.units - requestedSlidingUsage, resetAfter: resetAfter)
            )
        }

        slidingWindows[storageKey] = retainedEntries
        let retryAfter = retainedEntries.first.map { entry in
            remainingDuration(interval: interval, elapsedMilliseconds: instant.elapsedMilliseconds(since: entry.instant))
        } ?? interval
        return .rejected(
            RateLimitRejection(
                remainingUnits: limit.units - usedUnits,
                retryAfter: retryAfter,
                resetAfter: retryAfter
            )
        )
    }

    private func evaluateTokenBucket(
        request: RateLimitRequest,
        capacity: RateLimitLimit,
        refillAmount: RateLimitLimit,
        refillInterval: RateLimitDuration,
        instant: RateLimitInstant
    ) -> RateLimitDecision {
        let storageKey = StorageKey(key: request.key, policy: request.policy)
        var state = tokenBuckets[storageKey] ?? TokenBucketState(availableUnits: capacity.units, lastRefill: instant)
        state = refilledTokenBucket(
            state: state,
            capacity: capacity,
            refillAmount: refillAmount,
            refillInterval: refillInterval,
            instant: instant
        )

        guard request.cost.units <= capacity.units else {
            tokenBuckets[storageKey] = state
            return .rejected(
                RateLimitRejection(
                    remainingUnits: state.availableUnits,
                    retryAfter: refillInterval,
                    resetAfter: refillInterval,
                    reason: .costExceedsLimit
                )
            )
        }

        if state.availableUnits >= request.cost.units {
            state.availableUnits -= request.cost.units
            tokenBuckets[storageKey] = state
            return .allowed(
                RateLimitGrant(remainingUnits: state.availableUnits, resetAfter: refillInterval)
            )
        }

        tokenBuckets[storageKey] = state
        let missingUnits = request.cost.units - state.availableUnits
        let intervalsNeeded = divideRoundingUp(missingUnits, by: refillAmount.units)
        let retryAfter = refillInterval.multiplied(by: intervalsNeeded)
        return .rejected(
            RateLimitRejection(
                remainingUnits: state.availableUnits,
                retryAfter: retryAfter,
                resetAfter: retryAfter
            )
        )
    }

    private func refilledTokenBucket(
        state: TokenBucketState,
        capacity: RateLimitLimit,
        refillAmount: RateLimitLimit,
        refillInterval: RateLimitDuration,
        instant: RateLimitInstant
    ) -> TokenBucketState {
        let elapsed = instant.elapsedMilliseconds(since: state.lastRefill)
        guard elapsed >= refillInterval.milliseconds else {
            return state
        }
        let completedIntervals = UInt64(elapsed / refillInterval.milliseconds)
        let added = completedIntervals.saturatingProduct(refillAmount.units)
        let updatedUnits = min(capacity.units, state.availableUnits.saturatingSum(added))
        let intervalMultiplier = completedIntervals > UInt64(Int64.max) ? Int64.max : Int64(completedIntervals)
        let advancedMilliseconds = refillInterval.milliseconds.saturatingProduct(intervalMultiplier)
        let updatedInstant = state.lastRefill.advanced(by: RateLimitDuration(checkedMilliseconds: advancedMilliseconds))
        return TokenBucketState(availableUnits: updatedUnits, lastRefill: updatedInstant)
    }

    private func remainingDuration(interval: RateLimitDuration, elapsedMilliseconds: Int64) -> RateLimitDuration {
        let remaining = interval.milliseconds - min(max(0, elapsedMilliseconds), interval.milliseconds)
        return RateLimitDuration(checkedMilliseconds: max(1, remaining))
    }

    private func divideRoundingUp(_ value: UInt64, by divisor: UInt64) -> UInt64 {
        guard divisor > 0 else {
            return 1
        }
        let quotient = value / divisor
        let remainder = value % divisor
        return remainder == 0 ? quotient : quotient + 1
    }
}

private extension UInt64 {
    func saturatingSum(_ other: UInt64) -> UInt64 {
        let result = addingReportingOverflow(other)
        return result.overflow ? UInt64.max : result.partialValue
    }

    func saturatingProduct(_ other: UInt64) -> UInt64 {
        let result = multipliedReportingOverflow(by: other)
        return result.overflow ? UInt64.max : result.partialValue
    }
}

private extension Int64 {
    func saturatingProduct(_ other: Int64) -> Int64 {
        let result = multipliedReportingOverflow(by: other)
        return result.overflow ? Int64.max : result.partialValue
    }
}
