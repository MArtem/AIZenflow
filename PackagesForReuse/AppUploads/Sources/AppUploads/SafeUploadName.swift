import Foundation

public struct SafeUploadName: Hashable, Codable, Sendable, CustomStringConvertible {
    public let value: String

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 160 else {
            throw UploadFailure(.invalidName, operation: .validation)
        }
        guard trimmed != ".", trimmed != ".." else {
            throw UploadFailure(.invalidName, operation: .validation)
        }
        guard trimmed.contains("/") == false, trimmed.contains("\\") == false else {
            throw UploadFailure(.invalidName, operation: .validation)
        }
        guard trimmed.rangeOfCharacter(from: .controlCharacters) == nil else {
            throw UploadFailure(.invalidName, operation: .validation)
        }
        let blockedCharacters = CharacterSet(charactersIn: ":*?\"<>|")
        guard trimmed.rangeOfCharacter(from: blockedCharacters) == nil else {
            throw UploadFailure(.invalidName, operation: .validation)
        }
        self.value = trimmed
    }

    public var description: String {
        "SafeUploadName(redacted)"
    }
}
