import Foundation

public enum ObservabilityErrorCategory: String, Codable, Hashable, Sendable {
    case network
    case persistence
    case validation
    case permission
    case cancellation
    case timeout
    case configuration
    case unknown
}

public struct ObservabilityErrorDescriptor: Codable, Hashable, Sendable {
    public let category: ObservabilityErrorCategory
    public let code: String
    public let isRetryable: Bool?

    public init(
        category: ObservabilityErrorCategory,
        code: String,
        isRetryable: Bool? = nil
    ) {
        self.category = category
        self.code = code
        self.isRetryable = isRetryable
    }

    public static let operationFailed = ObservabilityErrorDescriptor(
        category: .unknown,
        code: "operation_failed",
        isRetryable: nil
    )

    public static let cancelled = ObservabilityErrorDescriptor(
        category: .cancellation,
        code: "cancelled",
        isRetryable: false
    )
}

public protocol ObservabilityErrorDescribing: Error, Sendable {
    var observabilityErrorDescriptor: ObservabilityErrorDescriptor { get }
}
