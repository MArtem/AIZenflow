import Foundation

public struct UploadRequest: Sendable, CustomStringConvertible {
    public let id: UploadID
    public let url: URL
    public let method: UploadHTTPMethod
    public let payload: UploadPayload
    public let maximumPayloadBytes: Int64?
    public let maximumResponseBytes: Int64?
    public let retryPolicy: UploadRetryPolicy
    public let allowedSchemes: Set<String>

    public init(
        id: UploadID,
        url: URL,
        method: UploadHTTPMethod = .post,
        payload: UploadPayload,
        maximumPayloadBytes: Int64? = nil,
        maximumResponseBytes: Int64? = nil,
        retryPolicy: UploadRetryPolicy = .singleAttempt,
        allowedSchemes: Set<String> = ["https"]
    ) throws {
        let normalizedSchemes = Set(allowedSchemes.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
        guard normalizedSchemes.isEmpty == false else {
            throw UploadFailure(.invalidURL, operation: .validation)
        }
        guard let scheme = url.scheme?.lowercased(), normalizedSchemes.contains(scheme) else {
            throw UploadFailure(.invalidURL, operation: .validation)
        }
        if let maximumPayloadBytes, maximumPayloadBytes <= 0 {
            throw UploadFailure(.invalidPayload, operation: .validation)
        }
        if let maximumResponseBytes, maximumResponseBytes <= 0 {
            throw UploadFailure(.invalidPayload, operation: .validation)
        }
        self.id = id
        self.url = url
        self.method = method
        self.payload = payload
        self.maximumPayloadBytes = maximumPayloadBytes
        self.maximumResponseBytes = maximumResponseBytes
        self.retryPolicy = retryPolicy
        self.allowedSchemes = normalizedSchemes
    }

    public var description: String {
        "UploadRequest(id: redacted, url: \(UploadURLRedactor.redacted(url)), method: \(method.rawValue), payload: \(payload.description))"
    }
}
