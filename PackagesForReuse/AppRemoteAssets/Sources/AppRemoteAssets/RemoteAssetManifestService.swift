import Foundation

public actor RemoteAssetManifestService {
    private let transport: any RemoteAssetManifestDataTransport
    private let decoder: JSONDecoder

    public init(
        transport: any RemoteAssetManifestDataTransport,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.transport = transport
        self.decoder = decoder
    }

    public func loadManifest(_ request: RemoteAssetManifestRequest) async throws -> RemoteAssetManifest {
        let response = try await transport.loadData(for: request)
        guard request.acceptedStatusCodes.contains(response.statusCode) else {
            throw RemoteAssetFailure(code: .unacceptableStatusCode, context: "status-\(response.statusCode)")
        }
        guard response.payload.count <= request.maximumResponseBytes else {
            throw RemoteAssetFailure(code: .responseTooLarge)
        }
        do {
            return try decoder.decode(RemoteAssetManifest.self, from: response.payload)
        } catch {
            throw RemoteAssetFailure(code: .decodingFailed)
        }
    }
}
