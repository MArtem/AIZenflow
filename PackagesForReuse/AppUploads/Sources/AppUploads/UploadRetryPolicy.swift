import Foundation

public struct UploadRetryPolicy: Hashable, Codable, Sendable {
    public let maximumAttempts: Int
    public let delayNanoseconds: UInt64

    public init(maximumAttempts: Int = 1, delayNanoseconds: UInt64 = 0) throws {
        guard maximumAttempts >= 1, maximumAttempts <= 8 else {
            throw UploadFailure(.invalidPayload, operation: .validation)
        }
        self.maximumAttempts = maximumAttempts
        self.delayNanoseconds = delayNanoseconds
    }

    public static let singleAttempt = UploadRetryPolicy.unchecked(maximumAttempts: 1, delayNanoseconds: 0)

    private static func unchecked(maximumAttempts: Int, delayNanoseconds: UInt64) -> UploadRetryPolicy {
        UploadRetryPolicy(maximumAttempts: maximumAttempts, delayNanoseconds: delayNanoseconds, trusted: ())
    }

    private init(maximumAttempts: Int, delayNanoseconds: UInt64, trusted: Void) {
        self.maximumAttempts = maximumAttempts
        self.delayNanoseconds = delayNanoseconds
    }
}
