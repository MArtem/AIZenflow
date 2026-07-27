import XCTest
@testable import AppRateLimiter

final class AppRateLimiterTests: XCTestCase {
    func testKeyRejectsUnsafeCharacters() throws {
        XCTAssertThrowsError(try RateLimitKey("user/123"))
        XCTAssertThrowsError(try RateLimitKey(""))
        let key = try RateLimitKey("route.login")
        XCTAssertFalse(key.description.contains("route.login"))
    }

    func testFixedWindowRejectsUntilWindowResets() async throws {
        let clock = ManualRateLimitClock()
        let limiter = AppRateLimiter(clock: clock)
        let request = RateLimitRequest(
            key: try RateLimitKey("route.login"),
            policy: .fixedWindow(limit: try RateLimitLimit(2), interval: try .seconds(10)),
            cost: try RateLimitCost(1)
        )

        let firstDecision = try await limiter.evaluate(request)
        XCTAssertTrue(firstDecision.isAllowed)
        let secondDecision = try await limiter.evaluate(request)
        XCTAssertTrue(secondDecision.isAllowed)
        let rejected = try await limiter.evaluate(request)
        XCTAssertFalse(rejected.isAllowed)
        XCTAssertEqual(rejected.retryAfter?.milliseconds, 10_000)

        await clock.advance(by: try .seconds(10))
        let afterResetDecision = try await limiter.evaluate(request)
        XCTAssertTrue(afterResetDecision.isAllowed)
    }

    func testSlidingWindowReleasesOldEntries() async throws {
        let clock = ManualRateLimitClock()
        let limiter = AppRateLimiter(clock: clock)
        let request = RateLimitRequest(
            key: try RateLimitKey("route.search"),
            policy: .slidingWindow(limit: try RateLimitLimit(2), interval: try .seconds(10)),
            cost: try RateLimitCost(1)
        )

        let firstDecision = try await limiter.evaluate(request)
        XCTAssertTrue(firstDecision.isAllowed)
        await clock.advance(by: try .seconds(5))
        let secondDecision = try await limiter.evaluate(request)
        XCTAssertTrue(secondDecision.isAllowed)
        let rejectedDecision = try await limiter.evaluate(request)
        XCTAssertFalse(rejectedDecision.isAllowed)
        await clock.advance(by: try .seconds(5))
        let releasedDecision = try await limiter.evaluate(request)
        XCTAssertTrue(releasedDecision.isAllowed)
    }

    func testTokenBucketRefillsByCompletedIntervals() async throws {
        let clock = ManualRateLimitClock()
        let limiter = AppRateLimiter(clock: clock)
        let request = RateLimitRequest(
            key: try RateLimitKey("endpoint.assets"),
            policy: try .makeTokenBucket(
                capacity: try RateLimitLimit(3),
                refillAmount: try RateLimitLimit(1),
                refillInterval: try .seconds(2)
            ),
            cost: try RateLimitCost(1)
        )

        let firstDecision = try await limiter.evaluate(request)
        XCTAssertTrue(firstDecision.isAllowed)
        let secondDecision = try await limiter.evaluate(request)
        XCTAssertTrue(secondDecision.isAllowed)
        let thirdDecision = try await limiter.evaluate(request)
        XCTAssertTrue(thirdDecision.isAllowed)
        let rejectedDecision = try await limiter.evaluate(request)
        XCTAssertFalse(rejectedDecision.isAllowed)
        await clock.advance(by: try .seconds(2))
        let refilledDecision = try await limiter.evaluate(request)
        XCTAssertTrue(refilledDecision.isAllowed)
    }

    func testResetAllowsNewEvaluation() async throws {
        let clock = ManualRateLimitClock()
        let limiter = AppRateLimiter(clock: clock)
        let key = try RateLimitKey("operation.sync")
        let request = RateLimitRequest(
            key: key,
            policy: .fixedWindow(limit: try RateLimitLimit(1), interval: try .minutes(1)),
            cost: try RateLimitCost(1)
        )

        let firstDecision = try await limiter.evaluate(request)
        XCTAssertTrue(firstDecision.isAllowed)
        let rejectedDecision = try await limiter.evaluate(request)
        XCTAssertFalse(rejectedDecision.isAllowed)
        try await limiter.reset(key: key)
        let afterResetDecision = try await limiter.evaluate(request)
        XCTAssertTrue(afterResetDecision.isAllowed)
    }

    func testRejectsCostAbovePolicyMaximumWithExplicitReason() async throws {
        let limiter = AppRateLimiter()
        let fixedWindowRequest = RateLimitRequest(
            key: try RateLimitKey("route.expensive"),
            policy: .fixedWindow(limit: try RateLimitLimit(2), interval: try .seconds(10)),
            cost: try RateLimitCost(3)
        )
        let fixedWindowDecision = try await limiter.evaluate(fixedWindowRequest)
        guard case .rejected(let fixedWindowRejection) = fixedWindowDecision else {
            return XCTFail("Expected fixed-window request to be rejected")
        }
        XCTAssertEqual(fixedWindowRejection.reason, .costExceedsLimit)

        let tokenBucketRequest = RateLimitRequest(
            key: try RateLimitKey("route.upload"),
            policy: try .makeTokenBucket(
                capacity: try RateLimitLimit(2),
                refillAmount: try RateLimitLimit(1),
                refillInterval: try .seconds(10)
            ),
            cost: try RateLimitCost(3)
        )
        let tokenBucketDecision = try await limiter.evaluate(tokenBucketRequest)
        guard case .rejected(let tokenBucketRejection) = tokenBucketDecision else {
            return XCTFail("Expected token-bucket request to be rejected")
        }
        XCTAssertEqual(tokenBucketRejection.reason, .costExceedsLimit)
    }

    func testStoreFailuresPropagateToHostPolicyBoundary() async throws {
        let limiter = AppRateLimiter(store: FailingRateLimitStore())
        let request = RateLimitRequest(
            key: try RateLimitKey("route.store"),
            policy: .fixedWindow(limit: try RateLimitLimit(1), interval: try .seconds(10)),
            cost: try RateLimitCost(1)
        )

        do {
            _ = try await limiter.evaluate(request)
            XCTFail("Expected store failure to propagate")
        } catch let error as TestRateLimitStoreFailure {
            XCTAssertEqual(error, .unavailable)
        }
    }

    func testCodableRoundTripForPolicy() throws {
        let policy = RateLimitPolicy.slidingWindow(
            limit: try RateLimitLimit(5),
            interval: try .seconds(30)
        )
        let data = try JSONEncoder().encode(policy)
        let decoded = try JSONDecoder().decode(RateLimitPolicy.self, from: data)
        XCTAssertEqual(policy, decoded)
    }
}


private enum TestRateLimitStoreFailure: Error, Equatable {
    case unavailable
}

private actor FailingRateLimitStore: RateLimitStore {
    func evaluate(_ request: RateLimitRequest, at instant: RateLimitInstant) async throws -> RateLimitDecision {
        throw TestRateLimitStoreFailure.unavailable
    }

    func reset(key: RateLimitKey) async throws {
        throw TestRateLimitStoreFailure.unavailable
    }

    func resetAll() async throws {
        throw TestRateLimitStoreFailure.unavailable
    }
}
