import Foundation

public struct UploadResponse: Sendable, Equatable, Codable, CustomStringConvertible {
    public let id: UploadID
    public let statusCode: Int
    public let responseByteCount: Int
    public let completedAt: Date

    public init(id: UploadID, statusCode: Int, responseByteCount: Int, completedAt: Date = Date()) {
        self.id = id
        self.statusCode = statusCode
        self.responseByteCount = max(0, responseByteCount)
        self.completedAt = completedAt
    }

    public var description: String {
        "UploadResponse(id: redacted, statusCode: \(statusCode), responseByteCount: \(responseByteCount))"
    }
}
