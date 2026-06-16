import Foundation

public struct AppTaskID: Hashable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    private let storage: String

    public init(_ value: String) throws {
        guard Self.isValid(value) else {
            throw AppTaskQueueFailure.invalidIdentifier
        }
        self.storage = value
    }

    public var storageKey: String { storage }

    public var description: String { "AppTaskID(redacted)" }

    public var debugDescription: String { description }

    private static func isValid(_ value: String) -> Bool {
        guard (1...128).contains(value.count) else { return false }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")
        return value.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
}
