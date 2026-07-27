import Foundation

public struct UploadFormField: Hashable, Codable, Sendable, CustomStringConvertible {
    public let name: SafeUploadName
    public let value: String

    public init(name: SafeUploadName, value: String) throws {
        guard value.rangeOfCharacter(from: .controlCharacters.subtracting(.newlines)) == nil else {
            throw UploadFailure(.invalidPayload, operation: .validation)
        }
        self.name = name
        self.value = value
    }

    public var description: String {
        "UploadFormField(name: redacted, value: redacted)"
    }
}
