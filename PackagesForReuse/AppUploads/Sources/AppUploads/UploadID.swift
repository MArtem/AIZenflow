import Foundation

public struct UploadID: Hashable, Codable, Sendable, CustomStringConvertible {
    public let value: String

    public init(_ value: String = UUID().uuidString) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 128 else {
            throw UploadFailure(.invalidIdentifier, operation: .validation)
        }
        guard trimmed.unicodeScalars.allSatisfy({ scalar in
            CharacterSet.alphanumerics.contains(scalar) || scalar == "-" || scalar == "_" || scalar == "."
        }) else {
            throw UploadFailure(.invalidIdentifier, operation: .validation)
        }
        self.value = trimmed
    }

    public var description: String {
        "UploadID(redacted)"
    }
}
