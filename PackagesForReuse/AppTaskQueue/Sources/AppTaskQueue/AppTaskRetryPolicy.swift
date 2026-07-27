import Foundation

public struct AppTaskRetryPolicy: Codable, Equatable, Sendable, CustomStringConvertible {
    public static let maximumSupportedAttempts = 25

    public static let noRetry = AppTaskRetryPolicy(maximumAttempts: 1, initialDelay: 0, multiplier: 1, maximumDelay: 0)
    public static let standard = AppTaskRetryPolicy(maximumAttempts: 3, initialDelay: 1, multiplier: 2, maximumDelay: 60)

    public let maximumAttempts: Int
    public let initialDelay: TimeInterval
    public let multiplier: Double
    public let maximumDelay: TimeInterval

    public init(
        maximumAttempts: Int,
        initialDelay: TimeInterval,
        multiplier: Double,
        maximumDelay: TimeInterval
    ) {
        self.maximumAttempts = maximumAttempts
        self.initialDelay = initialDelay
        self.multiplier = multiplier
        self.maximumDelay = maximumDelay
    }

    public func validated() throws -> Self {
        guard (1...Self.maximumSupportedAttempts).contains(maximumAttempts),
              initialDelay >= 0,
              multiplier >= 1,
              maximumDelay >= 0,
              maximumDelay >= initialDelay,
              initialDelay.isFinite,
              multiplier.isFinite,
              maximumDelay.isFinite else {
            throw AppTaskQueueFailure.invalidRetryPolicy
        }
        return self
    }

    public func canRetry(afterAttemptCount attemptCount: Int) -> Bool {
        attemptCount < maximumAttempts
    }

    public func delay(afterAttemptCount attemptCount: Int) -> TimeInterval {
        guard attemptCount > 0, initialDelay > 0 else { return 0 }
        let exponent = max(0, attemptCount - 1)
        let scaled = initialDelay * pow(multiplier, Double(exponent))
        guard scaled.isFinite else { return maximumDelay }
        return min(maximumDelay, scaled)
    }

    public var description: String {
        "AppTaskRetryPolicy(maximumAttempts: \(maximumAttempts), initialDelay: \(initialDelay), multiplier: \(multiplier), maximumDelay: \(maximumDelay))"
    }
}
