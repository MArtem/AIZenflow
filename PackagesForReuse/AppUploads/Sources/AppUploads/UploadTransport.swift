import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol UploadTransport: Sendable {
    func send(
        _ upload: PreparedUpload,
        progress: (@Sendable (UploadProgress) -> Void)?
    ) async throws -> UploadResponse
}

public actor FoundationUploadTransport: UploadTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(
        _ upload: PreparedUpload,
        progress: (@Sendable (UploadProgress) -> Void)? = nil
    ) async throws -> UploadResponse {
        progress?(UploadProgress(id: upload.id, sentBytes: 0, expectedBytes: upload.expectedByteCount))
        var request = URLRequest(url: upload.url)
        request.httpMethod = upload.method.rawValue
        request.setValue(upload.mediaType.value, forHTTPHeaderField: "Content-Type")
        request.setValue(String(upload.expectedByteCount), forHTTPHeaderField: "Content-Length")

        let result: (Data, URLResponse)
        do {
            result = try await session.upload(for: request, from: upload.payloadData)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            if Task.isCancelled {
                throw CancellationError()
            }
            throw UploadFailure(.transportUnavailable, operation: .transport)
        }
        guard let httpResponse = result.1 as? HTTPURLResponse else {
            throw UploadFailure(.invalidResponse, operation: .transport)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw UploadFailure(.invalidResponse, operation: .transport)
        }
        progress?(UploadProgress(id: upload.id, sentBytes: upload.expectedByteCount, expectedBytes: upload.expectedByteCount))
        return UploadResponse(id: upload.id, statusCode: httpResponse.statusCode, responseByteCount: result.0.count)
    }
}
