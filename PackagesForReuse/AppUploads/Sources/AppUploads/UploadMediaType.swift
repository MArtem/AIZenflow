import Foundation

public struct UploadMediaType: Hashable, Codable, Sendable, CustomStringConvertible {
    public let value: String

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 128 else {
            throw UploadFailure(.invalidMediaType, operation: .validation)
        }
        guard trimmed.contains("/") else {
            throw UploadFailure(.invalidMediaType, operation: .validation)
        }
        guard trimmed.rangeOfCharacter(from: .newlines) == nil else {
            throw UploadFailure(.invalidMediaType, operation: .validation)
        }
        guard trimmed.rangeOfCharacter(from: .controlCharacters) == nil else {
            throw UploadFailure(.invalidMediaType, operation: .validation)
        }
        self.value = trimmed
    }

    public static let binary = UploadMediaType(trustedValue: "application/octet-stream")
    public static let json = UploadMediaType(trustedValue: "application/json")
    public static let formData = UploadMediaType(trustedValue: "multipart/form-data")

    private init(trustedValue: String) {
        self.value = trustedValue
    }

    public var description: String {
        "UploadMediaType(\(value))"
    }
}
