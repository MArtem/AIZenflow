import Foundation

public struct DownloadID: Hashable, Sendable, Codable, CustomStringConvertible {
    private let storage: String

    private init(validated value: String) {
        self.storage = value
    }

    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw DownloadFailure(.invalidIdentifier, operation: .validation)
        }
        guard trimmed.count <= 128 else {
            throw DownloadFailure(.invalidIdentifier, operation: .validation)
        }
        guard trimmed.unicodeScalars.allSatisfy({ scalar in
            scalar.value <= 127 && (scalar.properties.isAlphabetic || scalar.properties.numericType != nil || scalar == "-" || scalar == "_")
        }) else {
            throw DownloadFailure(.invalidIdentifier, operation: .validation)
        }
        self.storage = trimmed
    }

    public static func generated() -> DownloadID {
        DownloadID(validated: UUID().uuidString)
    }

    public var value: String { storage }

    public var description: String {
        "DownloadID(redacted)"
    }
}
