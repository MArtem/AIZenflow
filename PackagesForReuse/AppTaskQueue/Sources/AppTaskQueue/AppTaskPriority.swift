import Foundation

public struct AppTaskPriority: Codable, Hashable, Comparable, Sendable, CustomStringConvertible {
    public static let lowest = AppTaskPriority(clamping: 0)
    public static let low = AppTaskPriority(clamping: 250)
    public static let normal = AppTaskPriority(clamping: 500)
    public static let high = AppTaskPriority(clamping: 750)
    public static let highest = AppTaskPriority(clamping: 1_000)

    public let value: Int

    public init(_ value: Int) throws {
        guard (0...1_000).contains(value) else {
            throw AppTaskQueueFailure.invalidPriority
        }
        self.value = value
    }

    private init(clamping value: Int) {
        self.value = min(1_000, max(0, value))
    }

    public static func < (lhs: AppTaskPriority, rhs: AppTaskPriority) -> Bool {
        lhs.value < rhs.value
    }

    public var description: String { "AppTaskPriority(value: \(value))" }
}
