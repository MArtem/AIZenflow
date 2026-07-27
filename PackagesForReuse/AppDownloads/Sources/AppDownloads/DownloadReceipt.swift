import Foundation

public struct DownloadReceipt: Equatable, Sendable, Codable, CustomStringConvertible {
    public let id: DownloadID
    public let fileName: SafeDownloadFileName
    public let directoryRole: DownloadDirectoryRole
    public let byteCount: Int64
    public let completedAt: Date

    public init(
        id: DownloadID,
        fileName: SafeDownloadFileName,
        directoryRole: DownloadDirectoryRole,
        byteCount: Int64,
        completedAt: Date
    ) {
        self.id = id
        self.fileName = fileName
        self.directoryRole = directoryRole
        self.byteCount = max(0, byteCount)
        self.completedAt = completedAt
    }

    public var description: String {
        "DownloadReceipt(id: \(id), fileName: redacted, role: \(directoryRole), bytes: \(byteCount))"
    }
}
