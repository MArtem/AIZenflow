import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct DownloadResponse: Sendable {
    public let data: Data
    public let expectedBytes: Int64?
    public let suggestedFileName: SafeDownloadFileName?

    public init(data: Data, expectedBytes: Int64? = nil, suggestedFileName: SafeDownloadFileName? = nil) {
        self.data = data
        self.expectedBytes = expectedBytes
        self.suggestedFileName = suggestedFileName
    }
}

public protocol DownloadTransport: Sendable {
    func response(for request: DownloadRequest) async throws -> DownloadResponse
}

public actor FoundationDownloadTransport: DownloadTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func response(for request: DownloadRequest) async throws -> DownloadResponse {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = "GET"
        let result: (Data, URLResponse)
        do {
            result = try await session.data(for: urlRequest)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            if Task.isCancelled {
                throw CancellationError()
            }
            throw DownloadFailure(.transportUnavailable, operation: .transport)
        }
        guard let httpResponse = result.1 as? HTTPURLResponse else {
            throw DownloadFailure(.invalidResponse, operation: .transport)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw DownloadFailure(.invalidResponse, operation: .transport)
        }
        if let maximumAllowedBytes = request.maximumAllowedBytes, Int64(result.0.count) > maximumAllowedBytes {
            throw DownloadFailure(.responseTooLarge, operation: .transport)
        }
        return DownloadResponse(data: result.0, expectedBytes: httpResponse.expectedContentLength > 0 ? httpResponse.expectedContentLength : nil)
    }
}
