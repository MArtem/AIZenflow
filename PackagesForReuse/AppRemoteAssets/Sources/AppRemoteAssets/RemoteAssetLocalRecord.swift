import Foundation

public struct RemoteAssetLocalRecord: Hashable, Codable, Sendable, CustomStringConvertible {
    public let id: RemoteAssetID
    public let version: RemoteAssetVersion
    public let storedAt: Date
    public let validatedAt: Date?
    public let byteCount: Int64?

    public init(
        id: RemoteAssetID,
        version: RemoteAssetVersion,
        storedAt: Date,
        validatedAt: Date? = nil,
        byteCount: Int64? = nil
    ) throws {
        if let byteCount, byteCount < 0 {
            throw RemoteAssetFailure(code: .invalidByteCount)
        }
        self.id = id
        self.version = version
        self.storedAt = storedAt
        self.validatedAt = validatedAt
        self.byteCount = byteCount
    }

    public var description: String {
        "RemoteAssetLocalRecord(id: redacted, version: redacted, byteCount: \(byteCount ?? -1))"
    }
}
