import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol RemoteAssetManifestDataTransport: Sendable {
    func loadData(for request: RemoteAssetManifestRequest) async throws -> RemoteAssetManifestDataResponse
}

public actor FoundationRemoteAssetManifestDataTransport: RemoteAssetManifestDataTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func loadData(for request: RemoteAssetManifestRequest) async throws -> RemoteAssetManifestDataResponse {
        do {
            let (data, response) = try await session.data(from: request.url)
            guard data.count <= request.maximumResponseBytes else {
                throw RemoteAssetFailure(code: .responseTooLarge)
            }
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
            return RemoteAssetManifestDataResponse(statusCode: statusCode, payload: data)
        } catch is CancellationError {
            throw CancellationError()
        } catch let failure as RemoteAssetFailure {
            throw failure
        } catch {
            if Task.isCancelled {
                throw CancellationError()
            }
            throw RemoteAssetFailure(code: .transportFailed)
        }
    }
}
