import Foundation

public struct UploadFileReference: Hashable, Codable, Sendable, CustomStringConvertible {
    public let fileURL: URL
    public let fieldName: SafeUploadName
    public let fileName: SafeUploadName
    public let mediaType: UploadMediaType
    public let declaredByteCount: Int64?

    public init(
        fileURL: URL,
        fieldName: SafeUploadName,
        fileName: SafeUploadName,
        mediaType: UploadMediaType = .binary,
        declaredByteCount: Int64? = nil
    ) throws {
        guard fileURL.isFileURL else {
            throw UploadFailure(.invalidPayload, operation: .validation)
        }
        if let declaredByteCount, declaredByteCount < 0 {
            throw UploadFailure(.invalidPayload, operation: .validation)
        }
        self.fileURL = fileURL
        self.fieldName = fieldName
        self.fileName = fileName
        self.mediaType = mediaType
        self.declaredByteCount = declaredByteCount
    }

    public var description: String {
        "UploadFileReference(field: redacted, file: redacted, mediaType: \(mediaType.value), bytes: \(declaredByteCount.map(String.init) ?? "unknown"))"
    }
}
