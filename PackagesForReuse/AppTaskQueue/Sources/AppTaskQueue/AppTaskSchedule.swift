import Foundation

public struct AppTaskSchedule: Codable, Equatable, Sendable, CustomStringConvertible {
    public static let immediate = AppTaskSchedule(notBefore: nil)

    public let notBefore: Date?

    public init(notBefore: Date?) {
        self.notBefore = notBefore
    }

    public func isDue(at date: Date) -> Bool {
        guard let notBefore else { return true }
        return notBefore <= date
    }

    public var description: String {
        "AppTaskSchedule(deferred: \(notBefore != nil))"
    }
}
