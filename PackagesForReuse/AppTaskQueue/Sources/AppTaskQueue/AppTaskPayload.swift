import Foundation

public struct AppTaskPayload: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public static let defaultMaximumBytes = 1_048_576

    public let data: Data
    public let mediaType: String?

    public init(
        data: Data,
        mediaType: String? = nil,
        maximumBytes: Int = Self.defaultMaximumBytes
    ) throws {
        guard maximumBytes > 0, data.count <= maximumBytes else {
            throw AppTaskQueueFailure.invalidPayloadSize(maximumBytes: maximumBytes)
        }
        if let mediaType {
            guard Self.isValidMediaType(mediaType) else {
                throw AppTaskQueueFailure.invalidMediaType
            }
        }
        self.data = data
        self.mediaType = mediaType
    }

    public var byteCount: Int { data.count }

    public var description: String {
        "AppTaskPayload(byteCount: \(data.count), mediaTypeProvided: \(mediaType != nil))"
    }

    public var debugDescription: String { description }

    private static func isValidMediaType(_ value: String) -> Bool {
        guard value == value.trimmingCharacters(in: .whitespacesAndNewlines),
              (3...127).contains(value.count),
              value.contains("/") else { return false }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$&^_.+-/;=")
        return value.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
}
