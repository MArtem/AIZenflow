import Foundation

public struct PreparedUpload: Sendable, CustomStringConvertible {
    public let id: UploadID
    public let url: URL
    public let method: UploadHTTPMethod
    public let mediaType: UploadMediaType
    public let payloadData: Data
    public let expectedByteCount: Int64

    public init(
        id: UploadID,
        url: URL,
        method: UploadHTTPMethod,
        mediaType: UploadMediaType,
        payloadData: Data
    ) throws {
        guard payloadData.isEmpty == false else {
            throw UploadFailure(.invalidPayload, operation: .validation)
        }
        self.id = id
        self.url = url
        self.method = method
        self.mediaType = mediaType
        self.payloadData = payloadData
        self.expectedByteCount = Int64(payloadData.count)
    }

    public var description: String {
        "PreparedUpload(id: redacted, url: \(UploadURLRedactor.redacted(url)), method: \(method.rawValue), mediaType: \(mediaType.value), bytes: \(expectedByteCount))"
    }
}
