import Foundation

public struct UploadProgress: Equatable, Codable, Sendable, CustomStringConvertible {
    public let id: UploadID
    public let sentBytes: Int64
    public let expectedBytes: Int64?

    public init(id: UploadID, sentBytes: Int64, expectedBytes: Int64?) {
        self.id = id
        self.sentBytes = max(0, sentBytes)
        self.expectedBytes = expectedBytes
    }

    public var fractionCompleted: Double? {
        guard let expectedBytes, expectedBytes > 0 else { return nil }
        return min(1, Double(sentBytes) / Double(expectedBytes))
    }

    public var description: String {
        "UploadProgress(id: redacted, sentBytes: \(sentBytes), expectedBytes: \(expectedBytes.map(String.init) ?? "unknown"))"
    }
}
